/*
EVENT - BASED
CORE SYNTHDEFS FOR CLEAN
(REQUIRED: CORE MODULES)
these synthdefs can be hacked at runtime, but they are absolutely necessary for everything to work correctly.
Their name and parameter names shouldn't be changed. Parameter names can be added though.
live coding them requires that you have your SuperClean instance in an environment variable called ~clean.

A quick note for hackers: You might think that default values for parameters get set in the SynthDefs, but alas
they do not. Default values for parameters get set in CleanAux.sc

*/

(
{
	var numChannels = ~clean.numChannels;

	(1..SuperClean.maxSampleNumChannels).do { |sampleNumChannels|

		var name = format("clean_sample_%_%", sampleNumChannels, numChannels);

		SynthDef(name, { |out, bufnum, sustain = 1, bgn = 0, end = 1, spd = 1, endspd = 1, freq = 440, pan = 0|

			var sound, rate, phase, sawrate, numFrames;

			// playback speed
			rate = Line.kr(spd, endspd, sustain) * (freq / 60.midicps);

			// sample phase
			// BufSampleRate adjusts the rate if the sound file doesn't have the same rate as the soundcard
			phase =  Sweep.ar(1, rate * BufSampleRate.ir(bufnum)) + (BufFrames.ir(bufnum) * bgn);

			numFrames = BufFrames.ir(bufnum);
			sawrate = rate * BufSampleRate.ir(bufnum) / (absdif(bgn, end) * numFrames);

			sound = BufRd.ar(
				numChannels: sampleNumChannels,
				bufnum: bufnum,
				phase: phase,
				loop: 0,
				interpolation: 4
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
		//bandq = max(1, bandq); // limit quality, avoid division by zero
		bandq = bandq.clip(0, 1).linlin(0, 1, 1, 10000);
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

	~clean.addModule('shp',
		{ |cleanEvent|
			cleanEvent.sendSynth("clean_shape" ++ ~numChannels,
				[
					shp: ~shp,
					amp_compensation_amount: ~sac,
					lo: ~slo,
					hi: ~shi,
					offset: ~sho,
					lo_thresh: ~lot,
					hi_thresh: ~hit,
					out: ~out
			])

	}, { ~shp.notNil });

	SynthDef("clean_shape" ++ numChannels, {
		|out, shape = 0, amp = 1.0,  amp_compensation_amount = 0.99, lo = 1, hi = 0, offset = 0, lo_thresh = 0, hi_thresh = 0|
		var abs, diff;
		var signal = In.ar(out, numChannels);
		shape = min(shape, 1.0 - 4e-10).explin(0.001, 1, 0.0, 0.999999);
		amp_compensation_amount = amp_compensation_amount.linlin(0.0,1.0,0.0001,1.0);
		amp = 1.0 - (amp_compensation_amount * shape / (shape +amp_compensation_amount )) * amp;
		shape = (1.0 * shape) / (1.0 - shape);
		signal = (1 + shape) * signal / (1 + (shape * abs(signal)));
		offset = offset.linlin(0.0,1.0,1.0,5.0);
		hi = hi * offset; lo = lo * offset;
		abs = hi - lo;
		lo_thresh = lo_thresh.linlin(0.0,1.0,-1.0,1.0);
		lo = lo + (abs * lo_thresh);
		hi_thresh = hi_thresh.linlin(0.0,1.0,-1.0,1.0);
		hi = hi - (abs * hi_thresh);
		signal = Fold.ar(signal, lo, hi);
		diff = 1 - (lo - hi + (hi * lo));
		ReplaceOut.ar(out, Limiter.ar(LeakDC.ar(signal * (amp+diff))));
	}, [\ir, \ir]).add;

	SynthDef("clean_envelope" ++ numChannels, { |out, attack = 0, hold = 0, release = inf, crv = 0.3 |
		var signal = In.ar(out, numChannels);
		signal = signal * EnvGen.ar(Env.linen(attack, hold, release, 1, crv));
		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir, \ir]).add;

	/*SynthDef("clean_tremolo" ++ numChannels, { |out, tremolorate = 1.0, tremolodepth = 0.5 |
		var signal, tremolowave;

		tremolodepth = tremolodepth.clip(0, 1) * 0.5;
		tremolowave = (1 - tremolodepth) + SinOsc.ar(tremolorate, 0.5pi, tremolodepth);

		signal = In.ar(out, numChannels);
		signal = signal * tremolowave;

		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir]).add;*/

	/*// Phaser audio DSP effect definition. Params: phaserrate (Hz); phaserdepth (amplitude)
	SynthDef("clean_phaser" ++ numChannels, { |out, phaserrate = 1.0, phaserdepth = 0.5, sustain = 4 |
		var signal, phaserwave;
		var phase =  LFPar.kr(phaserrate).range(0.0088, 0.01);

		phaserdepth = phaserdepth.clip(0, 1);

		signal = In.ar(out, numChannels);

		phaserwave = AllpassL.ar(signal, sustain, phase, 0, phaserdepth);

		signal = signal + phaserwave;

		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir]).add;*/

	// Waveloss
	// Divides an audio stream into tiny segments, using the signal's
	// zero-crossings as segment boundaries, and discards a fraction of them.

	~clean.addModule('wls', { |cleanEvent|
		cleanEvent.sendSynth('wls' ++ ~clean.numChannels,
			[
				wls: ~wls,
				out: ~out
			]
		)
	}, { ~wls.notNil });

	SynthDef("wls" ++ ~clean.numChannels, { |out, wls = 1|
		var sig = In.ar(out, ~clean.numChannels);
		sig = WaveLoss.ar(sig, wls, outof: 100, mode: 2);
		ReplaceOut.ar(out, sig)
	},[\ir, \ir]).add;

	// Squiz
	// "reminiscent of some weird mixture of filter, ring-modulator
	// and pitch-shifter"
	~clean.addModule('sqz', { |cleanEvent|
		cleanEvent.sendSynth('squiz' ++ ~clean.numChannels,
			[
				pitchratio: ~sqz,
				out: ~out
			]
		)
	}, { ~sqz.notNil });

	SynthDef("squiz" ++ ~clean.numChannels, { |out, pitchratio = 1|
		var sig = In.ar(out, ~clean.numChannels);
		sig = Squiz.ar(sig, pitchratio);
		ReplaceOut.ar(out, sig)
	}, [\ir, \ir]).add;

	// Frequency shifter
	// Total shift is sum of `fshift` (in Hz) and `fshiftnote` times the current note frequency.
	// `fshiftphase` allows control over the phase
	~clean.addModule('fsh', { |cleanEvent|
		cleanEvent.sendSynth("frequencyshifter" ++ ~clean.numChannels,
			[
				fsh: ~fsh,
				fsp: ~fsp,
				fsm: ~fsm,
				freq: ~freq,
				out: ~out
			]
		)
	}, { ~fsh.notNil });

	SynthDef("frequencyshifter" ++ ~clean.numChannels, { |out, fsh, fsp, fsm, freq|
		var sig = In.ar(out, ~clean.numChannels);
		var shift = freq * fsm + fsh;
		sig = FreqShift.ar(sig, shift, fsp);
		ReplaceOut.ar(out, sig);
	}, [\ir, \ir, \ir, \ir, \ir]).add;

	// Triode-like distortion, uses only the `tri` parameter
	~clean.addModule('tri', { |cleanEvent|
		cleanEvent.sendSynth("triode" ++ ~clean.numChannels,
			[
				tri: ~tri,
				out: ~out
			]
		)
	}, { ~tri.notNil });

	SynthDef("triode" ++ ~clean.numChannels, { |out, tri|
		var sig, sc;
		sig = In.ar(out, ~clean.numChannels);
		sc = tri * 10 + 0.001;
		sig = (sig * (sig > 0)) + (tanh(sig * sc) / sc * (sig < 0));
		ReplaceOut.ar(out, LeakDC.ar(sig));
	}, [\ir, \ir]).add;

	// This is apparantly the octaver from Sonic Pi
	// uses `oc1` for octave harmonics, `oc2` for half-frequency harmonics, and `oc3` for quarter-frequency harmonics
	~clean.addModule('oct', { |cleanEvent|
		cleanEvent.sendSynth("clean_octer" ++ ~clean.numChannels,
			[
				octer: ~oc1,
				octersub: ~oc2,
				octersubsub: ~oc3,
				out: ~out
			]
		)
	}, { ~oc1.notNil or: { ~oc2.notNil } or: { ~oc3.notNil }});

	SynthDef("clean_octer" ++ ~clean.numChannels, { |out, octer, octersub, octersubsub|
		var signal, oct1, oct2, oct3, sub;
		signal = In.ar(out, ~clean.numChannels);
		oct1 = 2.0 * LeakDC.ar( abs(signal) );
		sub = LPF.ar(signal, 440);
		oct2 = ToggleFF.ar(sub);
		oct3 = ToggleFF.ar(oct2);
		signal = SelectX.ar(octer.abs.clip(0.0, 1.0), [signal, octer.abs.clip(0.0, 1.0) * oct1, DC.ar(0)]);
		signal = signal + (octersub * oct2 * sub) + (octersubsub * oct3 * sub);
		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir, \ir]).add;

	// Ring modulation
	~clean.addModule('rma', { |cleanEvent|
		cleanEvent.sendSynth("clean_rma" ++ ~clean.numChannels,
			[
				rma: ~rma,
				rmf: ~rmf,
				rdf: ~rdf,
				rdt: ~rdt,
				out: ~out
			]
		)
	}, { ~rma.notNil });

	SynthDef("clean_rma" ++ ~clean.numChannels, { |out, rma = 0, rmf = 0, rdf, rdt = 0.5|
		var signal, mod;
		signal = In.ar(out, ~clean.numChannels);
		mod = rma * SinOsc.ar(Clip.kr(XLine.kr(rdf, rmf, rdt), 20, 20000));
		signal = ring1(signal, mod); // Looks confusing huh? Well ring1, as it turns out, is an operator, search for it in the docs
		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir, \ir]).add;

	// A crunchy distortion with a lot of high harmonics, the only parameter is `dst`
	~clean.addModule('dst', { |cleanEvent|
		cleanEvent.sendSynth("clean_distortion" ++ ~clean.numChannels,
			[
				dst: ~dst,
				out: ~out
			]
		)
	}, { ~dst.notNil });

	SynthDef("clean_distortion" ++ ~clean.numChannels, { |out, dst = 0|
		var signal, mod;
		signal = In.ar(out, ~clean.numChannels);
		mod = CrossoverDistortion.ar(signal, amp: 0.2, smooth: 0.01);
		mod = mod + (0.1 * dst * DynKlank.ar(`[[60,61,240,3000 + SinOsc.ar(62,mul: 100)],nil,[0.1, 0.1, 0.05, 0.01]], signal));
		mod = (mod.cubed * 8).softclip * 0.5;
		mod = SelectX.ar(dst, [signal, mod]);
		Out.ar(out, mod);
	}, [\ir, \ir]).add;

	//These spectral effects below are Mads Kjeldgaard's handywork
	// Spectral delay
	~clean.addModule('sda', { |cleanEvent|
		cleanEvent.sendSynth('spectral-delay' ++ ~clean.numChannels,
			[
				xsdelay: ~sdx,
				tsdelay: ~sdt,
				sda: ~sda,
				sdq: ~sdq,
				out: ~out
			]
		)
	}, { ~sda.notNil });

	SynthDef("spectral-delay" ++ ~clean.numChannels, { |out, tsdelay = 0.5, xsdelay = 0.5, sda = 0, sdq = 0.005|

		var signal, delayTime, delays, freqs, filtered;
		var size = 16;
		var maxDelayTime = 0.2;
		signal = In.ar(out, ~clean.numChannels);
		delayTime = tsdelay * maxDelayTime;
		filtered = (1..size).sum { |i|
			var filterFreq = i.linexp(1, size, 40, 17000);
			var sig = BPF.ar(signal, filterFreq, sdq);
			// the delay pattern is determined from xsdelay by bitwise-and:
			DelayN.ar(sig, maxDelayTime, i & xsdelay * (1 / size) * delayTime )
		};
		signal = signal * 0.2 + ((filtered * 4) * sda); // this controls wet / dry
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	// Spectral freeze
	/*~clean.addModule('spectral-freeze', { |cleanEvent|
		cleanEvent.sendSynth('spectral-freeze' ++ ~clean.numChannels,
			[
				freeze: ~frz,
				out: ~out
			]
		)
	}, { ~frz.notNil } );


	SynthDef("spectral-freeze" ++ ~clean.numChannels, { |out, freeze| // broken, use at own risk, values seem to be 0 for off and 1 for on
	var signal, chain, in;
	signal = In.ar(out, ~clean.numChannels);
	chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
	signal = IFFT(PV_Freeze(chain, freeze));
	ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;
	*/

	// Spectral comb
	~clean.addModule('cmb', { |cleanEvent|
	cleanEvent.sendSynth('spectral-comb' ++ ~clean.numChannels,
	[
	comb: ~cmb,
	out: ~out
	]
	)
	}, { ~cmb.notNil });

	SynthDef("spectral-comb" ++ ~clean.numChannels, { |out, comb|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_RectComb(chain, numTeeth: teeth * comb.abs.clip(0.0, 1.0), width: 1-comb.abs.clip(0.0, 1.0)));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral smear
	~clean.addModule('smr', { |cleanEvent|
		cleanEvent.sendSynth('spectral-smear' ++ ~clean.numChannels,
			[
				smear: ~smr,
				out: ~out
			]
		)
	}, { ~smr.notNil });

	SynthDef("spectral-smear" ++ ~clean.numChannels, { |out, smear|
		var signal, chain, in;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_MagSmear(chain, bins: smear.linexp(0.0,1.0,1,64)));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral scramble
	~clean.addModule('scm', { |cleanEvent|
		cleanEvent.sendSynth('spectral-scram' ++ ~clean.numChannels,
			[
				scram: ~scm,
				out: ~out
			]
		)
	}, { ~scm.notNil });

	SynthDef("spectral-scram" ++ ~clean.numChannels, { |out, scram|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BinScramble(chain, wipe: scram, width: scram));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral binshift
	~clean.addModule('sbs', { |cleanEvent|
		cleanEvent.sendSynth('spectral-binshift' ++ ~clean.numChannels,
			[
				binshift: ~sbs,
				out: ~out
			]
		)
	}, { ~sbs.notNil });

	SynthDef("spectral-binshift" ++ ~clean.numChannels, { |out, binshift|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BinShift(chain, stretch: binshift.linlin(0.0,1.0,0.01,4.0),
			shift: binshift * 10, interp: 1));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral high pass filter
	~clean.addModule('hbr', { |cleanEvent|
		cleanEvent.sendSynth('spectral-hbrick' ++ ~clean.numChannels,
			[
				hbrick: ~hbr,
				out: ~out
			]
		)
	}, { ~hbrick.notNil });

	SynthDef("hbr" ++ ~clean.numChannels, { |out, hbrick|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BrickWall(chain, wipe: hbrick * 0.6)); // Signal almost disappears around 0.5 therefore it's scaled a bit
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral low pass filter
	~clean.addModule('lbr', { |cleanEvent|
		cleanEvent.sendSynth('spectral-lbrick' ++ ~clean.numChannels,
			[
				lbrick: ~lbr,
				out: ~out
			]
		)
	}, { ~lbrick.notNil });

	SynthDef("spectral-lbrick" ++ ~clean.numChannels, { |out, lbrick|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		// lbrick parameter scaled to negative range to activate lopass filter (see ugen help file)
		signal = IFFT(PV_BrickWall(chain, wipe: lbrick.linlin(0.0,1.0,0.0,(-1.0))));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Conformer
	~clean.addModule('scf', { |cleanEvent|
		cleanEvent.sendSynth('spectral-conformer' ++ ~clean.numChannels,
			[
				real: ~scf,
				imag: ~img,
				out: ~out
			]
		)
	}, { ~ral.notNil or: ~img.notNil });

	SynthDef("spectral-conformer" ++ ~clean.numChannels, { |out, real = 0.5, imag = 0.5|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(
			PV_ConformalMap(chain, real.linlin(0.0,1.0,0.01,2.0), imag.linlin(0.00,1.0,0.01,10.0))
		).tanh;
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	// Enhance
	~clean.addModule('enh', { |cleanEvent|
		cleanEvent.sendSynth('spectral-enhance' ++ ~clean.numChannels,
			[
				enhance: ~enh,
				out: ~out
			]
		)
	}, { ~enh.notNil });

	SynthDef("spectral-enhance" ++ ~clean.numChannels, { |out, enhance = 0.5|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(
			PV_SpectralEnhance(chain,
				enhance.linlin(0.0,1.0,1,16),
				enhance.linlin(0.0,1.0,1.0,5.0),
				enhance.linlin(0.0,1.0,0.0,0.99))
		).tanh; // .tanh is used as a crude limiter here beacause sometimes this ugen goes crazy
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// A low pass filter for the first half of the range, and a high pass for the rest.
	~clean.addModule('lhf', { |cleanEvent|
		cleanEvent.sendSynth('lhf-filter' ++ ~clean.numChannels,
			// OPTIONAL
			// passing this array of parameters could be left out,
			// but it makes it clear what happens
			[
				lhf: ~lhf,
				out: ~out
			]
	)}, { ~lhf.notNil});

	SynthDef("lhf-filter" ++ ~clean.numChannels, { |out, lhf|
		var signal;
		var lpfCutoffFreq = lhf.linexp(0, 0.5, 20, 10000);
		var hpfCutoffFreq = lhf.linexp(0.5, 1, 20, 10000);

		signal = In.ar(out, ~clean.numChannels);

		signal = RHPF.ar(
			RLPF.ar(
				signal,
				lpfCutoffFreq
			),
			hpfCutoffFreq
		);
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	/*
	// A nice reverb, behave very different on per event than on global, apply an env maybe for "reverse" reverb effect?
	~clean.addModule('nhh', { |cleanEvent|
		cleanEvent.sendSynth('nhh' ++ ~clean.numChannels,
			[
				nhh: ~nhh,
				rts: ~rts,
				bld: ~bld,
				lfc: ~lfc,
				lrt: ~lrt,
				hfc: ~hfc,
				hrt: ~hrt,
				edf: ~edf,
				ldf: ~ldf,
				mdr: ~mdr,
				mdd: ~mdd,
				out: ~out
			]
	)}, { ~nhh.notNil});

	SynthDef("nhh" ++ ~clean.numChannels, {|out, nhh, rts=1, bld=0.5, lfc=200, lrt=0.5, hfc=4000, hrt=0.5, edf=0.5, ldf=0.5, mdr=0.2, mdd=0.3|
        var sig, wet;
        sig = In.ar(out, ~clean.numChannels);
        wet = sig;
		wet = wet + NHHall.ar(wet, rts, bld, lfc, lrt, hfc, hrt, edf, ldf, mdr, mdd);
        sig = XFade2.ar(sig, wet, nhh);
        ReplaceOut.ar(out, sig)
	}, [\ir, \ir]).add;
*/

}.value
)