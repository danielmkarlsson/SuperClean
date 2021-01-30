/*

Add your own instruments in this file.

// supported parameters are:
// sustain, spd, endspd, bgn, end, pan, acc
// all instruments should use: out

If your SuperClean instance is assigned to the variable ~clean, you can livecode these synths.
*/

(

// An additive synth
	SynthDef(\add,  {| out, ada = 0.001, adr = 1,
	  amp = 1,
	  adc = 1,
	  freq = 200,
      pan = 0.5,
	  slw = 0.001|
	var ee,e,o;
		ee = Env([0,1,0],[ada,adr+slw],[-30,30]);
		e = Env.perc(ada,adr+0.0001,amp,adc);
		ee = EnvGen.ar(ee);
		e = EnvGen.ar(e,doneAction:2);
		o = SinOsc.ar(freq*ee);
		o = o * e * AmpComp.kr(freq,40,0.3);

		o = CleanPan.ar(o, ~clean.numChannels, pan);
		Out.ar(out, o);
	}).add;

// A four operator FM synth
 SynthDef(\fmx, {| sustain = 1, pan, amp = 0.1, out = 0,
    freq = 440, fdb = 0.8, hr4 = 1 ,hr3 = 2, hr2 = 1, hr1= 0, mi4 = 1, mi3 = 0.5,
	mi2 = 4, en1 = 0, en2 = 0, en3 = 0, en4 = 0, cu1 = 0, cu2 = 0, cu3 = 0,
	cu4 = 0, det = 0.0 |
    var env4,env3,env2,env1,sig,modComp;

    env4 = EnvGen.ar(Env.perc(en4,1-en4,curve:cu4),timeScale:sustain);
    env3 = EnvGen.ar(Env.perc(en3,1-en3,curve:cu3),timeScale:sustain);
    env2 = EnvGen.ar(Env.perc(en2,1-en2,curve:cu2),timeScale:sustain);
    env1 = EnvGen.ar(Env.perc(en1,1-en1,curve:cu1),timeScale:sustain,doneAction:2);

    modComp = freq.explin(20,20000,1,0.01);

    sig = SinOscFB.ar(freq*hr4,fdb*modComp,mi4*modComp ) * env4;
    sig = SinOsc.ar(freq*hr3,sig+[0,pi/2],mi3*modComp ) * env3;
    sig = SinOsc.ar(freq*hr2,sig,mi2*modComp ) * env2;
    sig = SinOsc.ar(freq*hr1+[det.neg,det], sig ) * env1;

    sig = sig * AmpCompA.kr(freq,17.323914436055);
    sig = (sig * amp)*LFNoise1.ar(0).range(1,1);
    sig = CleanPan.ar(sig, ~clean.numChannels, pan);
    Out.ar(out, tanh(LeakDC.ar(sig)));
  }).add;

// A sine oscillator
SynthDef("sin", {|out = 0, freq = 440, iph = 0, amp = 1.0, pan = 0, att = 0.0, rel = 1.0, crv = -8.0|
    var env, sig;
	env = Env.perc(att, rel, amp, crv).kr(doneAction: 2);
	sig = FSinOsc.ar(freq, iph, 0.75);
	sig = sig * env;
    sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig);
}).add;

// A saw oscillator
SynthDef("saw", {|out = 0, freq = 440, iph = 0.0, wid = 0.25, amp = 0.5, pan = 0, att = 0.0, rel = 1.0, crv = -8.0|
    var env, sig;
	env = Env.perc(att, rel, amp, crv).kr(doneAction: 2);
	sig = VarSaw.ar(freq, iph, wid, 0.75);
	sig = sig * env;
	sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, Pan2.ar(sig, pan));
}).add;


// A square oscillator
SynthDef("sqr", {|out = 0, freq = 440, amp = 0.5, pan = 0, att = 0.0, rel = 1.0, crv = -8.0, wid = 0.25|
    var env, sig;
	env = Env.perc(att, rel, amp, crv).kr(doneAction: 2);
	sig = Pulse.ar(freq, wid, 0.75);
	sig = sig * env;
	sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, Pan2.ar(sig, pan));
},
).add;


// live audio input, (does this really work tho?)
(
SynthDef(\in, { |out, sustain = 1, spd = 1, bgn = 0, end = 1, pan, accelerate, offset|
	var env, sound, rate, phase;
	phase = Line.ar(bgn, end, sustain);
	rate = (bgn + 1) * (spd + Sweep.kr(1, accelerate));
	sound = SoundIn.ar([0, 1]); // stereo in
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~clean.numChannels, pan)
	)
}).add
);

// read input from nth routing bus
// see also: effect "to"
(
SynthDef(\clean_from, { |out, sustain = 1, in, pan|
	var sound;
	sound = InFeedback.ar(in, ~clean.numChannels).poll;
	Out.ar(out,
		CleanPan.ar(sound, ~clean.numChannels, pan)
	)
}).add;

~clean.soundLibrary.addSynth(\from,
	(
		instrument: \clean_from,
		in: {
			~clean.audioRoutingBusses.wrapAt(~from ? 0).index
		}
	)
)
);

// pitch shifted live audio input (does this really work tho?)
(
SynthDef(\inr, { |out, sustain = 1, freq = 440, spd = 1, bgn=0, end=1, pan, bnd, offset|
	var env, sound, rate, phase;
	phase = Line.ar(bgn, end, sustain);
	rate = (bgn + 1) * (spd + Sweep.kr(1, bnd)) * freq / 440;
	sound = SoundIn.ar([0, 1]); // stereo in
	sound = PitchShift.ar(sound, 0.1, rate, 0.02, 0.01);
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~clean.numChannels, pan)
	)
}).add
);

// Karplus-Strong physical modeling of a vibrating string, using a delay line (CombL) excited by an intial pulse (Impulse)
// There are two delay lines
// "bnd" is used for a pitch glide, and "sustain" changes the envelope timescale
(
	SynthDef(\kps, {|out, sustain=1, pan, bnd, freq, detune=0.0 |
		var env = EnvGen.ar(Env.linen(0.002, 0.996, 0.002, 1,-3), timeScale:sustain, doneAction:2);
		var sound = Decay.ar(Impulse.ar(0,0,0.1), 0.1*(freq.cpsmidi)/69) * WhiteNoise.ar;
		var pitch = freq * Line.kr(1, 1+bnd, sustain);
		sound = CombC.ar(sound, 0.05, pitch.reciprocal*(1-(detune/100)), sustain) // remove detune because safety resons
		+ CombL.ar(sound, 0.05, pitch.reciprocal*(1+(detune/100)), sustain);
		OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env)) // move pan up before the two delay lines are introduced, hard pan them
	}).add
);

//  drum synthesis
// "sustain" controls the overall timescale, "pew" controls the filter sweep speed,
// and "fed" controls the sinewave feedback
(
	SynthDef(\drm, {|out, pew=1, sustain=1, pan, fed=0, tun |
		var env, sound, freq;
		tun = ((tun>0)*tun) + ((tun<1)*3);
		freq = (tun*10).midicps;
		env = EnvGen.ar(Env.linen(0.01, 0, 1, 1, -3), timeScale:sustain, doneAction:2);
		sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/pew), fed), 9000);
		OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env))
	}).add
);

// Hi-hat using Rumble-San's implementation as a starting point
// http://blog.rumblesan.com/post/53271713518/drum-sounds-in-supercollider-part-1
// using "num" in a weird way to provide some variation on the frequency
// "sustain" affects the overall envelope rate, "bnd" sweeps the filter
(
	SynthDef(\hat, {|out, sustain=1, pan, bnd, tun |
		var env, sound, accel, freq;
		env = EnvGen.ar(Env.linen(0.01, 0, 0.3, 1, -3), timeScale:sustain, doneAction:2);
		accel = Line.kr(1, 1+bnd.clip(-1.0,1.0), 0.2*sustain);
		freq = 2000*accel*(tun/5 + 1).wrap(0.5,2);
		sound = HPF.ar(LPF.ar(WhiteNoise.ar(1), 3*freq), freq);
		OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env))
	}).add
);

// Transient excited filter
SynthDef("dfd", {|out = 0, freq = 440, res = 0.999, den = 100, amp = 2, pan = 0.5, att = 0.0, rel = 1.0, crv = -8.0, typ = 0.0, noiselevel = 0|
	var env, sig;
	env = Env.perc(att, rel, amp, crv).kr(doneAction: 2);
	sig = DFM1.ar(Dust2.ar(den.dup(~clean.numChannels), amp), freq, res, 1, typ, noiselevel);	sig = sig * env;
	//sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig);
}).add;

// debug a few time related values
(
SynthDef(\debug, { |bgn = -1, end = -1, delta = -1, sustain = -1, unitDuration = -1, cycle = -1|
	cycle.poll(Impulse.kr(0), label: "cycle");
	bgn.poll(Impulse.kr(0), label: "bgn");
	end.poll(Impulse.kr(0), label: "end");
	delta.poll(Impulse.kr(0), label: "delta");
	sustain.poll(Impulse.kr(0), label: "sustain");
	unitDuration.poll(Impulse.kr(0), label: "unitDuration");
	DC.kr(0).poll(Impulse.kr(0), label: "\n\n");
}).add
);
)

