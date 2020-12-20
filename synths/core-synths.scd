/*

EVENT - BASED
CORE SYNTHDEFS FOR CLEAN
(REQUIRED: CORE MODULES)

these synthdefs can be hacked at runtime, but they are absolutely necessary for everything to work correctly.

Their name and parameter names shouldn't be changed. Parameter names can be added though.

live coding them requires that you have your SuperClean instance in an environment variable called ~clean.

*/

(
{
	var numChannels = ~clean.numChannels;



	// write variants for different sample buffer sizes
	(1..SuperClean.maxSampleNumChannels).do { |sampleNumChannels|

		var name = format("clean_sample_%_%", sampleNumChannels, numChannels);

		SynthDef(name, { |out, bufnum, sustain = 1, bgn = 0, end = 1, spd = 1, endspd = 1, freq = 440, pan = 0|

			var sound, rate, phase, sawrate, numFrames;

			// playback spd
			rate = Line.kr(spd, endspd, sustain) * (freq / 60.midicps);

			// sample phase
			// BufSampleRate adjusts the rate if the sound file doesn't have the same rate as the soundcard
			// phase =  Sweep.ar(1, rate * BufSampleRate.ir(bufnum)) + (BufFrames.ir(bufnum) * bgn);

			numFrames = BufFrames.ir(bufnum);
			sawrate = rate * BufSampleRate.ir(bufnum) / (absdif(bgn, end) * numFrames);
			phase = (spd.sign * LFSaw.ar(sawrate, 1)).range(bgn,end) * numFrames;

			sound = BufRd.ar(
				numChannels: sampleNumChannels,
				bufnum: bufnum,
				phase: phase,
				loop: 0,
				interpolation: 4 // cubic interpolation, do we need that? Really tho? Seems to just make playing long samples sound bad.
			);

			sound = CleanPan.ar(sound, numChannels, pan);

			Out.ar(out, sound)
		}, [\ir, \ir, \ir, \ir, \ir, \ir, \ir, \ir]).add;
	};

	/*

	Bus Routing Monitor

	*/


	// the monitor does the mixing and zeroing of the busses for each sample grain
	// so that they can all play in one bus

	SynthDef("clean_gate" ++ numChannels, { |out, in, sustain = 1, fadeInTime = 0.0001, fadeTime = 0.0001, amp = 1|
		var signal = In.ar(in, numChannels);
		 //  doneAction: 14: free surrounding group and all nodes
		var env = EnvGen.ar(Env([0, 1, 1, 0], [fadeInTime, sustain, fadeTime], \sin), levelScale: amp, doneAction: 14);
		signal = signal * env * CleanGateCutGroup.ar(fadeTime, doneAction: 14);
		OffsetOut.ar(out, signal);
		ReplaceOut.ar(in, Silent.ar(numChannels)) // clears bus signal for subsequent synths
	}, [\ir, \ir, \ir, \ir, \ir, \ir]).add;


	/*

	Internal Signal Routing Synths

	*/

	SynthDef("clean_out" ++ numChannels, { |out, to, sustain = 1, fadeInTime = 0.0001, fadeTime = 0.0001, amp = 1|
		var signal = In.ar(out, numChannels);
		var env = EnvGen.ar(Env([0, 1, 1, 0], [fadeInTime, sustain, fadeTime], \sin), levelScale: amp);
		Out.ar(to, signal * env);
	}, [\ir, \ir]).add;

	/*

	Effect SynthDefs
	These per-sample-effects are freed after Monitor envelope has ended

	*/

	// would be nice to have some more parameters in some cases

	SynthDef("clean_crush" ++ numChannels, { |out, crush = 4|
		var signal = In.ar(out, numChannels);
		signal = signal.round(0.5 ** (crush-1));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	SynthDef("clean_coarse" ++ numChannels, { |out, coarse = 0, bandq = 10|
		var signal = In.ar(out, numChannels);
		signal = Latch.ar(signal, Impulse.ar(SampleRate.ir / coarse));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	SynthDef("clean_hpf" ++ numChannels, { |out, hcutoff = 440, hresonance = 0|
		var signal = In.ar(out, numChannels);
        var hcutoffClipped = hcutoff.abs.clip(20, 20000);
		signal = RHPF.ar(signal, hcutoffClipped, hresonance.linexp(0, 1, 1, 0.001));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	SynthDef("clean_bpf" ++ numChannels, { |out, bandqf = 440, bandq = 10|
		var signal = In.ar(out, numChannels);
		bandq = max(1, bandq);
		bandq = bandq.abs.clip(0.000001, 1); // limit quality, avoid division by zero
		bandqf = max(20, bandqf); // limit lower end, avoid blow up
		bandqf = bandqf.abs.clip(20, 20000);

		signal = BPF.ar(signal, bandqf, 1/bandq) * max(bandq, 1.0);
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	SynthDef("clean_lpf" ++ numChannels, { |out, cutoff = 440, resonance = 0|
		var signal = In.ar(out, numChannels);
		var cutoffClipped = cutoff.abs.clip(20, 20000);
		signal = RLPF.ar(signal, cutoffClipped, resonance.linexp(0, 1, 1, 0.001));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	SynthDef("clean_shape" ++ numChannels, { |out, shape = 0|
		var signal = In.ar(out, numChannels), amp = 1;
		shape = min(shape, 1.0 - 4e-10); // avoid division by zero
		//amp = 1.0 - (0.15 * shape / (shape + 2.0)) * amp; // optional amp comp
		shape = (2.0 * shape) / (1.0 - shape);

		signal = (1 + shape) * signal / (1 + (shape * abs(signal)));
		ReplaceOut.ar(out, signal * amp)
	}, [\ir, \ir]).add;

	SynthDef("clean_envelope" ++ numChannels, { |out, attack = 0, hold = 0, release = inf, crv = 0.3 |
		var signal = In.ar(out, numChannels);
		signal = signal * EnvGen.ar(Env.linen(attack, hold, release, 1, crv));
		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir, \ir]).add;

	SynthDef("clean_tremolo" ++ numChannels, { |out, tremolorate = 1.0, tremolodepth = 0.5 |
		var signal, tremolowave;

		tremolodepth = tremolodepth.clip(0, 1) * 0.5;
		tremolowave = (1 - tremolodepth) + SinOsc.ar(tremolorate, 0.5pi, tremolodepth);

		signal = In.ar(out, numChannels);
		signal = signal * tremolowave;

		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir]).add;

	// Phaser audio DSP effect definition. Params: phaserrate (Hz); phaserdepth (amplitude)
	SynthDef("clean_phaser" ++ numChannels, { |out, phaserrate = 1.0, phaserdepth = 0.5, sustain = 4 |
		var signal, phaserwave;
		var phase =  LFPar.kr(phaserrate).range(0.0088, 0.01);

		phaserdepth = phaserdepth.clip(0, 1);

		signal = In.ar(out, numChannels);

		phaserwave = AllpassL.ar(signal, sustain, phase, 0, phaserdepth);

		signal = signal + phaserwave;

		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir]).add;



}.value
)
