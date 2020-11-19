/*

Add your own instruments here.

// supported parameters are e.g.
// sustain, spd, endspd, bgn, end, pan, accelerate, offset, cps
// all instruments ought to use: out

If your SuperClean instance is assigned to the variable ~cln, you can livecode these synths.
*/

(




// modulated band limited impulse
(
SynthDef(\imp, { |out, sustain = 1, freq = 440, spd = 1, bgn=0, end=1, pan, accelerate, offset|
	var env, sound, rate, phase;
	env = EnvGen.ar(Env.perc(0.01, 0.99, 1, -1), timeScale:sustain, doneAction:2);
	phase = Line.kr(bgn, end, sustain);
	rate = (bgn + 1) * (spd + Sweep.kr(1, accelerate));
	sound = Blip.ar(rate.linexp(0, 1, 1, freq) * [1, 1.25, 1.51, 1.42], ExpRand(80, 118) * phase).sum;
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~cln.numChannels, pan, env)
	)
}).add
);


// modulated phase mod sines
(
SynthDef(\psin, { |out, sustain = 1, freq = 440, spd = 1, bgn=0, end=1, pan, accelerate, offset, modfreq = 40|
	var env, sound, rate, phase, amp;
	amp = AmpCompA.kr(freq);
	env = EnvGen.ar(Env.perc(0.002, sustain, 1, -1), doneAction:2);
	phase = Line.ar(bgn, end, sustain);
	rate = spd + Sweep.kr(1, accelerate);
	sound = SinOsc.ar(freq, SinOsc.ar(modfreq * (1..5), 0, 1 - phase * 10 * env / (1..5), 0.5pi)).sum;
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~cln.numChannels, pan, env)
	)
}).add
);

// cursor modulated phase mod sines
(
SynthDef(\pmsin, { |out, sustain = 1, freq = 440, spd = 1, bgn=0, end=1, pan, accelerate, offset|
	var env, sound, rate, phase, modfreq, amp;
	freq = (MouseX.kr(30, 80).round + freq);
	modfreq = MouseY.kr(1, 200, 1);
	amp = AmpCompA.kr(freq);
	env = EnvGen.ar(Env.perc(0.002, sustain, 1, -1), doneAction:2);
	phase = Line.ar(bgn, end, sustain);
	rate = spd + Sweep.kr(1, accelerate);
	sound = SinOsc.ar(freq, SinOsc.ar(modfreq * (1..5), 0, 1 - phase * 10 * env / (1..5), 0.5pi)).sum;
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~cln.numChannels, pan, env)
	)
}).add
);

// live audio input
(
SynthDef(\in, { |out, sustain = 1, spd = 1, bgn = 0, end = 1, pan, accelerate, offset|
	var env, sound, rate, phase;
	phase = Line.ar(bgn, end, sustain);
	rate = (bgn + 1) * (spd + Sweep.kr(1, accelerate));
	sound = SoundIn.ar([0, 1]); // stereo in
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~cln.numChannels, pan)
	)
}).add
);

// read input from nth routing bus
// see also: effect "to"
(
SynthDef(\clean_from, { |out, sustain = 1, in, pan|
	var sound;
	sound = InFeedback.ar(in, ~cln.numChannels).poll;
	Out.ar(out,
		CleanPan.ar(sound, ~cln.numChannels, pan)
	)
}).add;

~cln.soundLibrary.addSynth(\from,
	(
		instrument: \clean_from,
		in: {
			~cln.audioRoutingBusses.wrapAt(~from ? 0).index
		}
	)
)
);



// pitch shifted live audio input
(
SynthDef(\inr, { |out, sustain = 1, freq = 440, spd = 1, bgn=0, end=1, pan, accelerate, offset|
	var env, sound, rate, phase;
	phase = Line.ar(bgn, end, sustain);
	rate = (bgn + 1) * (spd + Sweep.kr(1, accelerate)) * freq / 440;
	sound = SoundIn.ar([0, 1]); // stereo in
	sound = PitchShift.ar(sound, 0.1, rate, 0.02, 0.01);
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~cln.numChannels, pan)
	)
}).add
);

// gabor grain
(
SynthDef(\gabor, { |out, sustain = 0.03, freq = 440, pan = 0, width = 0.3|
	var env, sound;
	sound = SinOsc.ar(freq, 0.5pi);
	env = LFGauss.ar(sustain, width, loop: 0).range(0, 1);
	OffsetOut.ar(out,
		CleanPan.ar(env * sound, ~cln.numChannels, pan)
	)
}).add;
);

// dirac delta function approximation
(
SynthDef(\dirac, { |out, sustain = 0.03, pan = 0|
	OffsetOut.ar(out,
		CleanPan.ar(Impulse.ar(0), ~cln.numChannels, pan)
	)
}).add;
);

// shepard on a cycle
(
SynthDef(\cyclo, { |out, freq, sustain = 1, spd = 1, bgn = 0, end = 1, pan, accelerate, cycle, ratio = 1|
	var env, sound, rate, phase;

	env = EnvGen.ar(Env.perc(0.01, 0.99, 1, -1), timeScale:sustain, doneAction:2);
	phase = Line.kr(bgn, 1 - end, sustain);
	rate = (bgn + 1) * (spd + Sweep.kr(1, accelerate));

	freq = (cycle * spd) % ((1..16) * ratio + phase) + 1 * freq * rate;

	sound = SinOsc.ar(freq).mean;
	OffsetOut.ar(out,
		CleanPan.ar(sound, ~cln.numChannels, pan, env)
	)
}).add
);

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

	SynthDef(\uio,  {
	| out, attack = 0.001, release = 1,
	  amp = 1,
	  curve = 1,
	  freq = 200,
	  dur = 0.25,
	  stereoDetune = 1,
      pan = 0.5
      |

	var ee,e,o;
		ee = Env([0,1,0],[attack,release+0.01],[-20,30]);
		e = Env.perc(attack,release+0.001,amp,curve);
		ee = EnvGen.ar(ee);
		e = EnvGen.ar(e,doneAction:2);
		o = SinOsc.ar(freq*ee);
		o = o * e * AmpComp.kr(freq,40,0.3);

		o = CleanPan.ar(o, ~cln.numChannels, pan);
		Out.ar(out, o);
	}, [\ir, \ir, \ir, \ir, \ir, \ir, \ir, \ir]).add;

 SynthDef(\fmx, {
    |
    sustain, pan, amp = 0.1, lforate = 0, lfodepth = 1, out = 0,
    freq = 440,
    fdb = 0.9,
    hr4 = 3 ,hr3 = 2, hr2 = 1, hr1= 1,
    mi4 = 2, mi3 = 3, mi2 = 4,
    en1 = 0, en2 = 0, en3 = 0, en4 = 0,
    cu1 = 0, cu2 = 0, cu3 = 0, cu4 = 0,
    det = 0.2
    |
    var env4,env3,env2,env1,sig,modComp;

    env4 = EnvGen.ar(Env.perc(en4,1-en4,curve:cu4),timeScale:sustain);
    env3 = EnvGen.ar(Env.perc(en3,1-en3,curve:cu3),timeScale:sustain);
    env2 = EnvGen.ar(Env.perc(en2,1-en2,curve:cu2),timeScale:sustain);
    env1 = EnvGen.ar(Env.perc(en1,1-en1,curve:cu1),timeScale:sustain,doneAction:2);

    modComp = freq.explin(20,20000,1,0.01);

    sig = SinOscFB.ar(freq*hr4,        fdb*modComp,  mi4*modComp  ) * env4;
    sig = SinOsc.ar(freq*hr3,        sig+[0,pi/2],  mi3*modComp  ) * env3;
    sig = SinOsc.ar(freq*hr2,        sig,      mi2*modComp  ) * env2;
    sig = SinOsc.ar(freq*hr1+[det.neg,det],  sig              ) * env1;

    sig = sig * AmpCompA.kr(freq,17.323914436055);
    sig = (sig * amp)*LFNoise1.ar(lforate).range(lfodepth,1);
    sig = CleanPan.ar(sig, ~cln.numChannels, pan);
    Out.ar(out, tanh(LeakDC.ar(sig)));
  }).add;

)
