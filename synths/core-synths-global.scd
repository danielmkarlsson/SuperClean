/*

AUX BASED (GLOBAL)
CORE SYNTHDEFS FOR CLEAN
(REQUIRED: GlobalCleanEffects)

Global synth defs: These synths run on each CleanAux and are only released when stopped.
If you make changes to them, hit cmd-period to update them.
They'll come back automatically.

*/

(
{
	var numChannels = ~clean.numChannels;

	/*

	Routing and Analysis

	*/

	SynthDef(\clean_monitor ++ numChannels, { |dryBus, effectBus, outBus, gate = 1|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		//var signal = XFade2.ar(wetSignal, drySignal, dry * 2 - 1);
		var signal = wetSignal + drySignal;
		var post = if(SuperClean.postBadValues) { 2 } { 0 };
		signal = Select.ar(CheckBadValues.ar(signal, post: post) > 0, [signal, DC.ar(0)]);
		signal = Limiter.ar(signal);

		// or if you like it harsher
		//signal = tanh(signal);
		// or:
		//signal = distort(signal);

		CleanPause.ar(signal, graceTime:4);
		signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(outBus, signal)
	}, [\ir, \ir, \kr, \kr]).add;

	// RMS measurement, sending back to editor
	SynthDef(\clean_rms ++ numChannels, { |gate = 1, dryBus, effectBus, rmsReplyRate = 20, rmsPeakLag = 3, auxIndex|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		var signal = wetSignal + drySignal;
		CleanPause.ar(signal, graceTime:8);
		EnvGen.kr(Env.asr, gate, doneAction:2);
		SendPeakRMS.kr(signal, replyRate: rmsReplyRate, peakLag: rmsPeakLag, cmdName:"/rms", replyID: auxIndex)
	}, [\kr, \ir, \ir, \kr, \kr, \kr]).add;

	/*

	Effect synths

	Each synth must have at least: dryBus, effectBus, gate

	dryBus and effectBus have \ir as rates (they shouldn't change at runtime)

	*/

	SynthDef(\clean_delay ++ numChannels, {
		|dryBus, effectBus, gate = 1, delaytime = 1, delayfeedback = 0.5, delaySend = 1, delayAmp = 1, lock = 0, cps = 1|
		var signal;
		var input = In.ar(dryBus, numChannels);
		var maxdelaytime = 128;
		input = input * delaySend.lag(LFNoise1.kr(1).range(0.01, 0.02)); // Regulate input.
		delaytime = delaytime * if(lock, reciprocal(cps), 1);
		delaytime = delaytime.clip(0, maxdelaytime); // Just to be sure.
		// From sc3-plugins.
		signal = \SwitchDelay.asClass.ar(input, 0, 1, delaytime, delayfeedback.clip(0.0, 1.0), maxdelaytime);
		//DetectSilence.ar(signal, time:1, doneAction: 1);
		// doesn't work properly. We don't really know when it's not used anymore.
		// this would have to be an explicit signal from sclang
		signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
		signal = signal * delayAmp.lag(0.01);
		CleanPause.ar(signal, graceTime:4);
		Out.ar(effectBus, signal);
	}, [\ir, \ir]).add;

	/*
	SynthDef ("tap"  ++ numChannels, {
	|dryBus, effectBus, gate = 1,  wow = 1, dropOuts = 1 |
	var in, del, sig, feed, svaj, amp;
	in = In.ar(dryBus, numChannels);
	in = tanh(in * 0.5);
	feed = in;
	amp = (LFNoise1.ar(15).range(0.8,1.1) * LFNoise1.ar(17).range(0.1,20).clip(0.3,1).lag(0.05));
	feed = feed * dropOuts.if(amp,1);
	svaj = LFNoise1.ar([2,9],[0.0011, 0.001]).sum.lag(0.4);
	svaj = svaj - svaj.clip2(0.0007);
	svaj = svaj * wow;
	del = DelayL.ar(HPF.ar(feed, 10).tanh, 2.0, 0.002 + svaj);
	sig = LeakDC.ar(del);
	Out.ar(effectBus, del);
	}, [\ir, \ir]).add;
	*/

	// As I understand it, this reverb was created by Jost Muxfeld and James McCartney, it is not my cup of tea.
	SynthDef(\clean_reverb ++ numChannels, { |dryBus, effectBus, gate = 1, rin = 0, rev = 0.1, dry = 0|
		var in, snd, loop, depth;
		in = In.ar(dryBus, numChannels).asArray.sum;
		in = in * rin.lag(LFNoise1.kr(1).range(0.01, 0.02)); // regulate input
		4.do { in = AllpassN.ar(in, 0.02, { Rand(0.005, 0.02) }.dup(numChannels), 1) };
		depth = rev.lag(0.02).linexp(0, 1, 0.01, 0.98); // change depth between 0.1 and 0.98
		loop = LocalIn.ar(numChannels) * { depth + Rand(0, 0.05) }.dup(numChannels);
		loop = OnePole.ar(loop, 0.5);  // 0-1
		loop = AllpassN.ar(loop, 0.05, { Rand(0.01, 0.05) }.dup(numChannels), 2);
		loop = DelayN.ar(loop, 0.3, [0.19, 0.26] + { Rand(-0.003, 0.003) }.dup(2));
		loop = AllpassN.ar(loop, 0.05, { Rand(0.03, 0.15) }.dup(numChannels), 2);
		loop = loop + in;
		loop = LeakDC.ar(loop);
		LocalOut.ar(loop);
		snd = loop;
		snd = snd * (1 - dry).lag(LFNoise1.kr(1).range(0.01, 0.02));
		CleanPause.ar(snd, graceTime:4);
		snd = snd * EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(effectBus, snd);
	}, [\ir, \ir]).add;

	// cav, pronounced "cave"
	SynthDef(\clean_cav ++ numChannels, {
		|dryBus, effectBus, gate = 1, in, out, cav = 0, cai = 1, cvt = 30, cvd = 0.5,  cvl = 1000|
		var sig, lgt = 0.5;
		sig = In.ar(dryBus, numChannels).asArray.sum;
		sig = GVerb.ar(
			sig * cai.clip(0.0, 1.0).lag(lgt),
			250,
			cvt.linlin(0.0, 1.0, 0.001, 30).lag(lgt),
			cvd.clip(0.0, 1.0).lag(lgt), 0.5, 15, 1, 0.7, 0.5);
		sig = LPF.ar(sig, cvl.lag(lgt).linexp(0.0, 1.0, 20.0, 1000.0));
		//sig = sig * (1 - cav.lag(lgt) - 1);
		sig = sig * cav.lag(lgt);
		CleanPause.ar(sig, graceTime:4);
		Out.ar(effectBus, sig);
	}, [\ir, \ir]).add;

	// Impulse Response based reverb
	//~path = Main.packages.asDict.at('SuperClean') +/+ "/clean-samples/mmd/mir/Large Church.aif";
	~path = Main.packages.asDict.at('SuperClean') +/+ "clean-samples" +/+ "mmd" +/+ "mir" +/+ "mir-4eqed.wav";
	~ezConvX = EZConvX(~path);
	SynthDef(\clean_mir ++ numChannels, {
		|dryBus, effectBus, gate = 1, in, out, mii = 1 mir = 0.0 |
		var sig, lgt = 0.5;
		sig = In.ar(dryBus, numChannels).asArray.sum;
		sig = ~ezConvX.ar(sig * mii.clip(0.0, 1.0).lag(lgt), leak: 0.1, mul: 1/16);
		sig = sig * (1 - mir.lag(lgt) - 1);
		CleanPause.ar(sig, graceTime:4);
		Out.ar(effectBus, sig);
	}, [\ir, \ir]).add;

	// NHHall based reverb
	SynthDef(\clean_hal ++ numChannels, {
		|dryBus, effectBus, gate=1, hal = 0, hai = 1, hhp=20, hlp=20000, rts=1, bld=0.5, edf=0.5, ldf=0.5|
		var lgt = 0.0625;
		var signal = In.ar(dryBus, numChannels);
		signal = signal * hai.lag(lgt);
		signal = HPF.ar(signal, hhp.clip(20,20000).lag(lgt));
		signal = LPF.ar(signal, hlp.clip(20,20000).lag(lgt));
		signal = signal.asArray.collect { |sig|
			NHHall.ar(Pan2.ar(sig), rts.clip(0,999).lag(lgt), bld.lag(0.5), 200, 0.5, 4000, 0.5,
				edf.clip(0,1).lag(lgt), ldf.clip(0,1).lag(lgt), 0, 0);
		};
		signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
		signal = LeakDC.ar(signal);
		signal = signal * hal.lag(lgt);
		CleanPause.ar(signal.sum, graceTime:4);
		Out.ar(effectBus, signal);
	}, [\ir, \ir]).add;

	SynthDef(\clean_tanh ++ numChannels, {
		|dryBus, effectBus, gate = 1, tnh = 0, tng = 1, tnb = 20000, tna = 20000|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		var sig = wetSignal + drySignal;
		var lgt = 0.0625;
		//sig = In.ar(dryBus, numChannels).asArray.sum;
		sig = LPF.ar(sig, tnb.clip(20, 20000).lag(lgt));
		sig = sig * tng.clip(0.0, 999.0).lag(0.1);
		sig = sig = tanh(sig);
		sig = LPF.ar(sig, tna.clip(20, 20000).lag(lgt));
		sig = LeakDC.ar(sig);
		sig = sig * tnh;
		CleanPause.ar(sig, graceTime:4);
		sig = sig * EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(effectBus, sig);
	}, [\ir, \ir]).add;

	SynthDef(\clean_dfm ++ numChannels, {
		|dryBus, effectBus, gate = 1, dfm = 0, dfg = 1, dfb = 20000, dfa = 20000, dff = 20000|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		var sig = wetSignal + drySignal;
		var lgt = 0.0625;
		sig = sig = DFM1.ar(sig, dff.clip(20, 20000).lag(12), 0.0, dfg.clip(0.0, 999.0).lag(0.1), 0.0, 0.0);
		//sig = LeakDC.ar(sig);
		sig = sig * dfm;
		CleanPause.ar(sig, graceTime:4);
		sig = sig * EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(effectBus, sig);
	}, [\ir, \ir]).add;

/*	SynthDef(\clean_trem ++ numChannels, {
		|dryBus, effectBus, gate = 1, trd=0.5, trr=0.25, tvr=0, tvd=0.0|
		var drySignal = In.ar(dryBus, numChannels);
		var wetSignal = In.ar(effectBus, numChannels);
		var sig = wetSignal + drySignal;
		var lgt = 0.5;
		var trem = trd.linlin(0.0, 1.0, 0.0, 2.0).lag(lgt) * SinOsc.kr(trr.clip(0, 999).lag(lgt) + LFNoise1.kr(tvr.linlin(0.0, 99.0, 0.0, 999.0).lag(lgt), tvd.clip(0, 999).lag(lgt)));
		var mix = 1 + trem;
		sig = sig * mix;
		CleanPause.ar(sig, graceTime:4);
		sig = sig * EnvGen.kr(Env.asr, gate, doneAction:2);
		Out.ar(effectBus, sig);
	}, [\ir, \ir]).add; */

	// JPverb based reverb
	SynthDef(\clean_jpverb ++ numChannels, {
		|dryBus, effectBus, gate=1, jpr=0, jpg=1, jts=1, jpd=0.8, jps=1.0, jed=1, jmd=0.0, jmf=0.3, jpl=0.8, jpm=0.6, jph=0.4, jlc=1, jhc=1|
        var lgt = 0.0625;
        var sig;
		sig = In.ar(dryBus, numChannels).asArray.sum;
		sig = sig * jpg.clip(0.0, 999.0);
		sig = sig = tanh(sig);
		sig = JPverb.ar(sig, jts.linlin(0.0, 1.0, 0.1, 60.0).lag.(lgt), jpd.clip(0.0, 1.0).lag.(lgt), jps.linlin(0.0, 1.0, 0.5, 5.0).lag.(lgt), jed.linlin(0.0,
            1.0, 0.8, 1.0).lag.(lgt), jmd.clip(0.0, 1.0).lag.(lgt), jmf.clip(0.0, 1.0).lag.(lgt), jpl.clip(0.0, 1.0).lag.(lgt), jpm.clip(0.0, 1.0).lag.(lgt), jph.clip(0.0, 1.0).lag.(lgt), jlc.linexp(0.0, 1.0, 100.0,
                6000.0).lag.(lgt), jhc.linexp(0.0, 1.0, 1000.0, 10000.0).lag.(lgt));
		sig = sig * jpr;
		CleanPause.ar(sig, graceTime:4);
		Out.ar(effectBus, sig);
	}, [\ir, \ir]).add;


	//"---- core synth defs loaded ----".postln;

}.value
);
