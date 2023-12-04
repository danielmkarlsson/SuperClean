(
/*
Function to store argument preset values for each synth. It will eventually be removed and added as a method for CleanSoundLibrary.
Use it by elsewhere by evaluating ~clean.soundLibrary.synthEvents[\preset][\store].(\superCleanSynthAbbrev)
Use it here by evaluating presetStore.(\superCleanSynthAbbrev)
Look up all default values by evaluating ~clean.soundLibrary.synthEvents[\preset]
Look up all default values for a specific synth by evaluating ~clean.soundLibrary.synthEvents[\preset][\superCleanSynthAbbrev]
And look up the default value for a synth's parameter by evaluating ~clean.soundLibrary.synthEvents[\preset][\superCleanSynthAbbrev][\synthArgName]
*/
var presetStore;
~clean.soundLibrary.synthEvents[\preset] ?? { ~clean.soundLibrary.synthEvents.put(\preset, Event(know:true)) };
presetStore = { |synth, verbose = false|
	var i;
	~clean.soundLibrary.synthEvents.keysValuesDo { |key, value|
		if (key == synth) {
			~clean.soundLibrary.synthEvents[\preset][synth] ?? { ~clean.soundLibrary.synthEvents[\preset].put(synth, ()) };
			i = value[0].at(\instrument);
			if (verbose) { i.postln };
			SynthDescLib.global.at(i).controlDict.do { |item|
				~clean.soundLibrary.synthEvents[\preset][synth].put(item.name, item.defaultValue);
				if (verbose) { [item.name, item.defaultValue].postln };
			}
		}
	}
};
~clean.soundLibrary.synthEvents[\preset][\store] ?? { ~clean.soundLibrary.synthEvents[\preset].put(\store, presetStore) };


// An additive synth.
SynthDef(\add,  {| out, ada = 0.001, adr = 1, amp = 1, adc = 1, freq = 200, pan = 0.5, slw = 0.001
	bnd = 0, bno = 0, bnt = 0.2, bnc = 0|
	var ee, e, o, freqclipped, gliss;
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 20000);
	ee = Env([0, 1, 0], [ada ,adr + slw], [-30, 30]);
	e = Env.perc(ada, adr + 0.0001, amp, adc);
	ee = EnvGen.ar(ee);
	e = EnvGen.ar(e, doneAction:2);
	o = SinOsc.ar(freqclipped * ee);
	o = o * e * AmpComp.kr(freqclipped, 40, 0.3);
	o = CleanPan.ar(o, ~clean.numChannels, pan);
	Out.ar(out, o);
}).store;


// A four operator FM synth.
SynthDef(\fmx, {| sustain = 1, pan, amp = 0.1, out = 0,
	freq = 440, mi1 = 0.8, hr4 = 1 ,hr3 = 2, hr2 = 1, hr1= 0, mi4 = 1, mi3 = 0.5,
	mi2 = 4, en1 = 0, en2 = 0, en3 = 0, en4 = 0, cu1 = 0, cu2 = 0, cu3 = 0,
	cu4 = 0, det = 0.0, bnd = 0, bno = 0, bnt = 0.2, bnc = 0|
	var env4, env3, env2, env1, sig, modComp, gliss, freqclipped;
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 20000);
	env4 = EnvGen.ar(Env.perc(en4, 1-en4, curve:cu4), timeScale:sustain);
	env3 = EnvGen.ar(Env.perc(en3, 1-en3, curve:cu3), timeScale:sustain);
	env2 = EnvGen.ar(Env.perc(en2, 1-en2, curve:cu2), timeScale:sustain);
	env1 = EnvGen.ar(Env.perc(en1, 1-en1, curve:cu1), timeScale:sustain, doneAction:2);
	modComp = freq.explin(20, 20000, 1, 0.01);
	sig = SinOscFB.ar(freqclipped * hr4, mi1 * modComp, mi4 * modComp) * env4;
	sig = SinOsc.ar(freqclipped * hr3, sig + [0, pi/2], mi3 * modComp) * env3;
	sig = SinOsc.ar(freqclipped * hr2, sig, mi2 * modComp) * env2;
	sig = SinOsc.ar(freqclipped * hr1 + [det.neg, det], sig ) * env1;
	sig = sig * AmpCompA.kr(freqclipped, 17.323914436055);
	sig = (sig * amp*0.7) * LFNoise1.ar(0).range(1, 1);
	sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, tanh(LeakDC.ar(sig)));
}).store;


// This synthdef builds on the work of Nathan Ho. https://nathan.ho.name/posts/ixa-synthesis/
SynthDef(\ixa, {| out, sustain = 1, pan, amp = 0.5, freq = 440, bnd = 0, bno = 0, bnt = 0.2, bnc = 0,
    bes = 2, abs = 2, ths = 2, ber = 1, abr = 1, thr = 1, crv, atk = 0.0, rel = 1.0|
	var phase;
	var slopeBelow, slopeAbove, threshold;
	var env, gliss, sig, freqclipped;
	env = Env.perc(atk, rel, amp, crv).kr(doneAction: 2);
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 20000);
	slopeBelow = LFNoise2.kr(bes).range(0, ber);
	slopeAbove = LFNoise2.kr(abs).range(0, abr);
	threshold = LFNoise2.kr(ths).range(0, thr);
	phase = Phasor.ar(0, freqclipped / SampleRate.ir, 0, 1);
	phase = Select.ar(phase > threshold, [phase * slopeAbove, threshold + ((phase - threshold) * slopeBelow)]);
	sig = SinOsc.ar(0, phase * 2pi);
	sig = sig * env;
    sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig * amp);
}).store;


// A sine wave oscillator.
SynthDef(\sin, {|out = 0, sustain = 1, bnd = 0, bno = 0, bnt = 0.2, bnc = 0, freq = 440, iph = 0, amp = 1.0,
	pan = 0, atk = 0.0, rel = 1.0, crv = -8.0|
	var env, gliss, sig, freqclipped;
	env = Env.perc(atk, rel, amp, crv).kr(doneAction: 2);
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 20000);
	sig = FSinOsc.ar(freqclipped, iph, 0.75);
	sig = sig * env;
	sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig);
}).store;


// A saw wave oscillator.
SynthDef(\saw, {|out = 0, sustain = 1, bnd = 0, bno = 0, bnt = 0.2, bnc = 0, freq = 440, iph = 0, wid = 0.25, amp = 1.0, pan = 0, atk = 0.0, rel = 1.0, crv = -8.0|
	var env, gliss, sig, freqclipped;
	env = Env.perc(atk, rel, amp, crv).kr(doneAction: 2);
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 20000);
	sig = VarSaw.ar(freqclipped, iph, wid, 0.75);
	sig = sig * env;
	sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig);
}).store;


// A square wave oscillator.
SynthDef(\sqr, {|out = 0, sustain = 1, bnd = 0, bno = 0, bnt = 0.2, bnc = 0, freq = 440, amp = 0.5, pan = 0, atk = 0.0, rel = 1.0, crv = -8.0, wid = 0.25|
	var env, gliss, sig, freqclipped;
	env = Env.perc(atk, rel, amp*0.5, crv).kr(doneAction: 2);
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 20000);
	sig = Pulse.ar(freqclipped, wid, 0.75);
	sig = sig * env;
	sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig);
},
).store;


// Live audio input, (does this really work tho?)
(
SynthDef(\in, { |out, sustain = 1, spd = 1, bgn = 0, end = 1, pan, glisserate, offset|
	var env, sound, rate, phase;
	//phase = Line.ar(bgn, end, sustain);
	//rate = (bgn + 1) * (spd + Sweep.kr(1, glisserate));
	sound = SoundIn.ar([0, 1]); // stereo in
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~clean.numChannels, pan)
	)
}).store
);


// Read input from nth routing bus.
// See also: effect "to".
(
SynthDef(\clean_from, { |out, sustain = 1, in, pan|
	var sound;
	sound = InFeedback.ar(in, ~clean.numChannels).poll;
	Out.ar(out,
		CleanPan.ar(sound, ~clean.numChannels, pan)
	)
}).store;

~clean.soundLibrary.addSynth(\from,
	(
		instrument: \clean_from,
		in: {
			~clean.audioRoutingBusses.wrapAt(~from ? 0).index
		}
	)
)
);


// Pitch shifted live audio input (does this really work tho?).
(
SynthDef(\inr, { |out, sustain = 1, freq = 440, spd = 1, bgn=0, end=1, pan, bnd, offset|
	var env, sound, rate, phase;
	//phase = Line.ar(bgn, end, sustain);
	rate = (bgn + 1) * (spd + Sweep.kr(1, bnd)) * freq / 440;
	sound = SoundIn.ar([0, 1]); // stereo in
	sound = PitchShift.ar(sound, 0.1, rate, 0.02, 0.01);
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~clean.numChannels, pan)
	)
}).store
);


// Karplus-Strong physical modeling of a vibrating string, using a delay line (CombL) excited by an intial pulse (Impulse).
// There are two delay lines.
// "bnd" is used for a pitch glide, and "sustain" changes the envelope timescale.
(
SynthDef(\kps, {|out, sustain=1, pan, bnd = 0, bno = 0, bnt = 0.2, bnc = 0, freq, detune=0.0|
	var gliss, freqclipped;
	var env = EnvGen.ar(Env.linen(0.002, 0.996, 0.002, 1,-3), timeScale:sustain, doneAction:2);
	var sound = Decay.ar(Impulse.ar(0,0,0.1), 0.1*(freq.cpsmidi)/69) * WhiteNoise.ar;
	var pitch = freq * Line.kr(1, 1 + 0, sustain);
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 20000);
	sound = CombC.ar(sound, 0.05, freqclipped.reciprocal*(1-(0/100)), sustain)
	+ CombL.ar(sound, 0.05, pitch.reciprocal*(1+(0/100)), sustain);
	OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env)) // move pan up before the two delay lines are introduced, hard pan them
}).store
);


// These kick and hat sounds build on the work of Rumble-San.
// http://blog.rumblesan.com/post/53271713518/drum-sounds-in-supercollider-part-1
//  A drum synth.
// "sustain" controls the overall timescale, "pew" controls the filter sweep speed,
// and "fed" controls the sinewave feedback.
(
SynthDef(\drm, {|out, pew=1, sustain=1, pan, fed=0, tun|
	var env, sound, freq;
	tun = ((tun>0)*tun) + ((tun<1)*3);
	freq = (tun*10).midicps;
	env = EnvGen.ar(Env.linen(0.01, 0, 1, 1, -3), timeScale:sustain, doneAction:2);
	sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/pew), fed), 9000);
	OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env))
}).store
);


// This uses "tun" in a weird way to provide some variation on the frequency.
// "sustain" affects the overall envelope rate.
// "bnd" sweeps the filter.
(
SynthDef(\hat, {|out, sustain=1, pan, bnd, tun|
	var env, sound, gliss, freq;
	env = EnvGen.ar(Env.linen(0.01, 0, 0.3, 1, -3), timeScale:sustain, doneAction:2);
	gliss = Line.kr(1, 1 + bnd.clip(-1.0, 1.0), 0.2 * sustain);
	freq = 2000 * gliss * (tun.clip(-1.0, 1.0) / 5 + 1).wrap(0.5, 2);
	sound = HPF.ar(LPF.ar(WhiteNoise.ar(1), 3 * freq), freq);
	OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env))
}).store
);


// Clap Synthesizer. This builds on the work of Nathan Ho: https://youtu.be/L9D78W8C-3w
// Call it by providing \clp as a value to the \snd key in a pattern.
// Parameters:
// srp | srq | bdy | bdt | tha | tho | fco | dmp
// amp | pan | atk | rel | crv | gate | sustain
// // (NEW: )
(
SynthDef(\cleanS_clap, {
	var out = \out.ir, amp = \amp.kr(0.35), pan = \pan.kr, attack = \attack.ir(0.05), release = \release.ir(0.7),
	ampEnvCurve = \ampEnvCurve.ir(-7), gate = \gate.kr(1), sustain = \sustain.kr(1), cutoff = \cutoff.kr(1611),
	resonance = \resonance.kr(0.5).clip(0.01, 1.0), sharpness = \sharpness.kr(0.35).linlin(0.0, 1.0, -500, 500),
	thumpAmp = \thumpAmp.kr(0.7), thumpOffset = \thumpOffset.kr(0.7), bendTime = \bendTime.kr(0.2).max(0),
	bendAmount = \bendAmount.kr(0.5).linlin(0.0, 1.0, 0.5, 1.0, nil), damping = \damping.kr(11000);
	var signal, thump, filterFreq, pitchEnv, clapEnv, thumpEnv, ampEnv;
	filterFreq = cutoff + sharpness;
	pitchEnv = Env([1, 1 + bendAmount, 1], bendTime * 0.5, \exp).kr(0, gate);
	clapEnv = Env([0, 1, 0, 0.8, 0, 0.7, 0], [0.001, 0.008, 0.001, 0.008, 0.001, release]).kr(0, gate);
	thumpEnv = Env.perc(0.001, 0.1, 1, 2).kr(0, gate);
	ampEnv = Env.perc(attack, release, 1, -7).kr(Done.freeSelf, gate, sustain);
	signal = Hasher.ar(Sweep.ar);
	thump = RHPF.ar(signal, filterFreq * thumpOffset * pitchEnv, 0.2) * thumpAmp * thumpEnv * 2;
	signal = BPF.ar(signal, filterFreq, resonance);
	signal = (signal * 30 * pitchEnv * 8).tanh;
	signal = (signal + thump).softclip;
	signal = signal.softclip * 1.4;
	signal = LPF.ar(signal, damping);
	signal = signal * clapEnv * ampEnv * (amp * 2); // amp * 3 --- level match scaling;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
    ReplaceOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\clp, (
	instrument: \cleanS_clap,
	attack: { ~atk ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\attack] } },
	release: { ~rel ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\release] } },
	ampEnvCurve: { ~crv ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\ampEnvCurve] } },
	sharpness: { ~srp ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\sharpness] } },
	resonance: { ~srq ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\resonance] } },
	damping: { ~dmp ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\damping] } },
	bendAmount: { ~bdy ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\bendAmount] } },
	bendTime: { ~bdt ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\bendTime] } },
	thumpAmp: { ~tha ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\thumpAmp] } },
	thumpOffset: { ~tho ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\thumpOffset] } },
	cutoff: { ~fco ?? { ~clean.soundLibrary.synthEvents[\preset][\clp][\cutoff] } }
), useSynthDefSustain: true);

presetStore.(\clp);
);


// Transient excited filter.
SynthDef(\dfd, {|out = 0, freq = 440, res = 1, den = 0, amp = 1, pan = 0.5, atk = 0.0, rel = 1.0, crv = -8.0, typ = 0.0, nsl = 0,
	bnd = 0, bno = 0, bnt = 0.2, bnc = 0|
	var env, sig, freqclipped, gliss;
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 7139);
	env = Env.perc(atk, rel, amp * 300, crv).kr(doneAction: 2);
	sig = DFM1.ar(Dust2.ar(den.dup(~clean.numChannels), amp), freqclipped, res.clip(0.0, 1.01), 1, typ, nsl);
	sig = sig * env;
	//sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig);
}).store;


// Digital wave guide physical model of a bowed instrument.
SynthDef(\bow, { |out=0, sustain = 1, freq=440, amp=1.0, frc=1, gate=1, pos=0.07, idc=0.25, hfl=31, pan=0, atk = 0.0, rel = 1.0,
	gst = 8.0, smp = 0.55, ihf = 2, bnd = 0, bno = 0, bnt = 0.2, bnc = 0|
	var env, vib, sig, freqclipped, gliss;
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 5000);
	env = Env.perc(atk, rel, amp * 0.666, gst).kr(doneAction: 2);
	sig = DWGBowed.ar(freqclipped, amp, frc, gate, pos, 0.1, idc, hfl, smp, ihf);
	sig = DWGSoundBoard.ar(sig);
	sig = BPF.ar(sig, 118, 1) + sig;
	sig = BPF.ar(sig, 430, 1) + sig;
	sig = BPF.ar(sig, 490, 1) + sig;
	sig = LPF.ar(sig, 4000);
	sig = sig * env;
	sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig);
}).store;

SynthDef(\blp, {|out = 0, sustain = 1, bnd = 0, bno = 0, bnt = 0.2, bnc = 0, freq = 440, nmh = 0, amp = 1.0,
	pan = 0, atk = 0.01, rel = 1.0, crv = -8.0|
	var env, gliss, sig, freqclipped;
	env = Env.perc(atk, rel, amp, crv).kr(doneAction: 2);
	gliss = EnvGen.kr(Env(
        [1, 1, 1 + bnd.clip(-1.0, 1.0)],
        [bno, bnt],
        [0, 0, bnc]  //optional curvature
    ));
	freqclipped = (freq * gliss).clip(20, 20000);
	sig = Blip.ar(freqclipped, nmh, 0.75);
	sig = sig * env;
	sig = CleanPan.ar(sig, ~clean.numChannels, pan);
	Out.ar(out, sig);
}).store;
)