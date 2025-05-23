/*
EVENT - BASED
CORE SYNTHDEF EFFECTS FOR SUPERCLEAN
These synthdefs can be hacked at runtime, and hey, if something breaks, you can always download a fresh version.
Live coding them requires that you have your SuperClean instance in an environment variable called ~clean.
A quick note for hackers: You might think that default values for parameters get set in
the SynthDefs, but alas they do not. Default values for parameters get set in CleanAux.sc
*/

(
{
	var numChannels = ~clean.numChannels;

	(1..SuperClean.maxSampleNumChannels).do { |sampleNumChannels|

		var name = format("clean_sample_%_%", sampleNumChannels, numChannels);

		SynthDef(name, { |out, bufnum, sustain = 1, bgn = 0, spd = 1, endspd = 1, freq = 440, pan = 0|

			var sound, rate, offset;

			// Playback speed.
			rate = Line.kr(spd, endspd, sustain) * (freq / 60.midicps);

			// Start position.
			// BufSampleRate adjusts the rate if the sound file doesn't have the same rate as the soundcard.
			offset = BufFrames.ir(bufnum) * bgn;

			sound = PlayBuf.ar(sampleNumChannels, bufnum, BufRateScale.ir(bufnum) * rate, startPos: offset, loop: 0.0, doneAction: 0);
			sound = CleanPan.ar(sound, numChannels, pan);

			Out.ar(out, sound)
		}, #[\ir, \ir, \ir, \ir, \ir, \ir, \ir, \kr]).add;

		name = format("clean_sampledisk_%_%", sampleNumChannels, numChannels);

		SynthDef(name, { |out, bufnum, sustain = 1, spd = 1, endspd = 1, freq = 440, pan = 0|

			var sound, rate;

			// Playback speed.
			rate = Line.kr(spd, endspd, sustain) * (freq / 60.midicps);

			sound = VDiskIn.ar(sampleNumChannels, bufnum, BufRateScale.ir(bufnum) * rate);
			sound = CleanPan.ar(sound, numChannels, pan);

			Out.ar(out, sound)
		}, #[\ir, \ir, \ir, \ir, \ir, \ir, \kr]).add;
	};

	/*
	Bus Routing Monitor
	*/

	// The monitor does the mixing and zeroing of the busses for each sample grain
	// so that they can all play in one bus.

	SynthDef(\clean_gate ++ numChannels, { |out, in, sustain = 1, fadeInTime = 0.0001, fadeTime = 0.0001, amp = 1|
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

	SynthDef(\clean_out ++ numChannels, { |out, to, sustain = 1, fadeInTime = 0.0001, fadeTime = 0.0001, amp = 1|
		var signal = In.ar(out, numChannels);
		var env = EnvGen.ar(Env([0, 1, 1, 0], [fadeInTime, sustain, fadeTime], \sin), levelScale: amp);
		Out.ar(to, signal * env);
	}, [\ir, \ir]).add;

	/*
	Effect SynthDefs
	These per-sample-effects are freed after Monitor envelope has ended.
	*/

	// This fuzz synthdef was originally designed by Jonathan Liljedahl. http://kymatica.com/
	~clean.addModule(\fuz, { |cleanEvent|
		cleanEvent.sendSynth(\fuz ++ ~clean.numChannels,
			[
				fuz: ~fuz,
				fzv: ~fzv,
				out: ~out
			]
	)}, { ~fuz.notNil or: { ~fzv.notNil and: { ~fuz != 0.0 } } });

	SynthDef (\fuz ++ ~clean.numChannels, { |out, fzv = 3|
		var sig, dry, gate;
		sig = In.ar(out, numChannels);
		gate = Amplitude.ar(sig,0.005, 0.005) > 0.002;
		sig = (sig * 4).tanh;
		sig = MidEQ.ar(sig, 100, 1, 20);
		dry = sig;
		sig = (Limiter.ar(sig * 50) * fzv).wrap(-1, 1) + sig;
		sig = sig.tanh;
		sig = MidEQ.ar(sig,200, 1, 20);
		sig = MidEQ.ar(sig,1000, 1, -20);
		sig = LPF.ar(sig, 8000);
		sig = (sig + dry).tanh;
		sig = MidEQ.ar(sig, 4000, 1, -20);
		ReplaceOut.ar(out, sig * gate)
	}, [\ir, \ir]).add;

	~clean.addModule(\bit,
	{ |cleanEvent|
		cleanEvent.sendSynth(\bit ++ ~numChannels,
			[
				crush: ~bit,
				out: ~out
		])

}, { ~bit.notNil });

	SynthDef(\bit ++ numChannels, { |out, crush = 4|
		var signal = In.ar(out, numChannels);
		signal = signal.round(0.5 ** (crush - 1));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	~clean.addModule(\sam,
	{ |cleanEvent|
		cleanEvent.sendSynth(\sam ++ ~numChannels,
			[
				coarse: ~sam,
				out: ~out
		])

}, { ~sam.notNil and: { ~sam > 1 } }); // coarse == 1 => full rate

	SynthDef(\sam ++ numChannels, { |out, coarse = 0, bandq = 10|
		var signal = In.ar(out, numChannels);
		signal = Latch.ar(signal, Impulse.ar(SampleRate.ir / coarse));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	~clean.addModule(\hpf,
	{ |cleanEvent|
		cleanEvent.sendSynth(\clean_hpf ++ ~numChannels,
			[
				hcutoff: ~hpf,
				hresonance: ~hpq,
				out: ~out
		])

}, { ~hpf.notNil });

	SynthDef(\clean_hpf ++ numChannels, { |out, hcutoff = 440, hresonance = 0|
		var signal = In.ar(out, numChannels);
		var hcutoffClipped = hcutoff.abs.clip(20, 20000);
		signal = RHPF.ar(signal, hcutoffClipped, hresonance.linexp(0, 1, 1, 0.001));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	~clean.addModule(\bpf,
	{ |cleanEvent|
		cleanEvent.sendSynth(\clean_bpf ++ ~numChannels,
			[
				bandqf: ~bpf,
				bandq: ~bpq,
				out: ~out
		])

}, { ~bpf.notNil });

	SynthDef(\clean_bpf ++ numChannels, { |out, bandqf = 440, bandq = 10|
		var signal = In.ar(out, numChannels);
		bandq = bandq.linlin(0, 1, 1, 10000);
		bandqf = max(20, bandqf); // limit lower end, avoid blow up
		bandqf = bandqf.abs.clip(20, 20000);

		signal = BPF.ar(signal, bandqf, 1/bandq) * max(bandq, 1.0);
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	~clean.addModule(\lpf,
	{ |cleanEvent|
		cleanEvent.sendSynth(\clean_lpf ++ ~numChannels,
			[
				cutoff: ~lpf,
				resonance: ~lpq,
				out: ~out
		])

}, { ~lpf.notNil });

	SynthDef(\clean_lpf ++ numChannels, { |out, cutoff = 440, resonance = 0|
		var signal = In.ar(out, numChannels);
		var cutoffClipped = cutoff.abs.clip(20, 20000);
		signal = RLPF.ar(signal, cutoffClipped, resonance.linexp(0, 1, 1, 0.001));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	~clean.addModule(\shp,
		{ |cleanEvent|
			cleanEvent.sendSynth(\clean_shape ++ ~numChannels,
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

	SynthDef(\clean_shape ++ numChannels, {
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

	~clean.addModule(\env,
	{ |cleanEvent|
		cleanEvent.sendSynth(\clean_envelope ++ ~numChannels,
			[
				attack: ~atk,
				hold: ~hld,
				release: ~rel,
				crv: ~crv,
				crt: ~crt,
				out: ~out
		])
}, { ~atk.notNil or: { ~rel.notNil }});

	SynthDef(\clean_envelope ++ numChannels, { |out, attack = 0, hold = 0, release = inf, crv = 0.3, crt = 0.3|
		var signal = In.ar(out, numChannels);
		signal = signal * EnvGen.ar(Env.linen(attack, hold, release, 1, [crv, 0, crt]), doneAction: 14);
		ReplaceOut.ar(out, signal);
	}, #[\ir, \ir, \ir, \ir, \ir, \ir]).add;

	// Frequency shifter
	// Total shift is sum of `fshift` (in Hz) and `fshiftnote` times the current note frequency.
	// `fshiftphase` allows control over the phase.
	~clean.addModule(\fsh, { |cleanEvent|
		cleanEvent.sendSynth(\frequencyshifter ++ ~clean.numChannels,
			[
				fsh: ~fsh,
				fsm: ~fsm,
				freq: ~freq,
				out: ~out
			]
		)
	}, { ~fsh.notNil });

	SynthDef(\frequencyshifter ++ ~clean.numChannels, { |out, fsh, fsp, fsm, freq|
		var sig = In.ar(out, ~clean.numChannels);
		var shift = freq * fsm + fsh;
		sig = FreqShift.ar(sig, shift, fsp);
		ReplaceOut.ar(out, sig);
	}, [\ir, \ir, \ir, \ir, \ir]).add;

	// Triode-like distortion, uses only the `tri` parameter.
	~clean.addModule(\tri, { |cleanEvent|
		cleanEvent.sendSynth(\triode ++ ~clean.numChannels,
			[
				tri: ~tri,
				out: ~out
			]
		)
	}, { ~tri.notNil });

	SynthDef(\triode ++ ~clean.numChannels, { |out, tri|
		var sig, sc;
		sig = In.ar(out, ~clean.numChannels);
		sc = tri * 10 + 0.001;
		sig = (sig * (sig > 0)) + (tanh(sig * sc) / sc * (sig < 0));
		ReplaceOut.ar(out, LeakDC.ar(sig));
	}, [\ir, \ir]).add;

	// This is apparently the octaver from Sonic Pi, which makes me guess that credit should go to Sam Aaron.
	// uses `ocu` for octave up , `ocd` for octave down, and `ocq` for quarter-frequency harmonics.
	~clean.addModule(\oct, { |cleanEvent|
		cleanEvent.sendSynth(\clean_octer ++ ~clean.numChannels,
			[
				octer: ~ocu,
				octersub: ~ocd,
				octersubsub: ~ocq,
				out: ~out
			]
		)
	}, { ~ocu.notNil or: { ~ocd.notNil } or: { ~ocq.notNil }});

	SynthDef(\clean_octer ++ ~clean.numChannels, { |out, octer, octersub, octersubsub|
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
	~clean.addModule(\rma, { |cleanEvent|
		cleanEvent.sendSynth(\clean_rma ++ ~clean.numChannels,
			[
				rma: ~rma,
				rmf: ~rmf,
				rdf: ~rdf,
				rdt: ~rdt,
				out: ~out
			]
		)
	}, { ~rma.notNil and: { ~rma != 0.0 and: { ~rmf != 0.0 and: { ~rdf != 0.0 } } } });

	SynthDef(\clean_rma ++ ~clean.numChannels, { |out, rma = 0, rmf = 0, rdf, rdt = 0.5|
		var signal, mod;
		signal = In.ar(out, ~clean.numChannels);
		mod = rma * SinOsc.ar(Clip.kr(XLine.kr(rmf, rdf, rdt), 0.01, 20000));
		signal = ring1(signal, mod); // Looks confusing huh? Well ring1, as it turns out, is an operator, search for it in the docs
		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir, \ir]).add;

	// A crunchy distortion with a lot of high harmonics, the only parameter is `dst`.
	~clean.addModule(\dst, { |cleanEvent|
		cleanEvent.sendSynth(\clean_distortion ++ ~clean.numChannels,
			[
				dst: ~dst,
				out: ~out
			]
		)
	}, { ~dst.notNil });

	SynthDef(\clean_distortion ++ ~clean.numChannels, { |out, dst = 0|
		var signal, mod;
		signal = In.ar(out, ~clean.numChannels);
		mod = CrossoverDistortion.ar(signal, amp: 0.2, smooth: 0.01);
		mod = mod + (0.1 * dst * DynKlank.ar(`[[60,61,240,3000 + SinOsc.ar(62,mul: 100)],nil,[0.1, 0.1, 0.05, 0.01]], signal));
		mod = (mod.cubed * 8).softclip * 0.5;
		mod = SelectX.ar(dst, [signal, mod]);
		Out.ar(out, mod);
	}, [\ir, \ir]).add;

	//These spectral effects below are Mads Kjeldgaard's handywork. https://madskjeldgaard.dk/
	// Spectral delay
	~clean.addModule(\sda, { |cleanEvent|
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

	SynthDef('spectral-delay' ++ ~clean.numChannels, { |out, tsdelay = 0.5, xsdelay = 0.5, sda = 0, sdq = 0.005|

		var signal, delayTime, filtered;
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
	SynthDef('spectral-freeze' ++ ~clean.numChannels, { |out, freeze| // broken, use at own risk, values seem to be 0 for off and 1 for on
	var signal, chain, in;
	signal = In.ar(out, ~clean.numChannels);
	chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
	signal = IFFT(PV_Freeze(chain, freeze));
	ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;
	*/

	// Spectral comb
	~clean.addModule(\cmb, { |cleanEvent|
		cleanEvent.sendSynth('spectral-comb' ++ ~clean.numChannels,
			[
				comb: ~cmb,
				out: ~out
			]
		)
	}, { ~cmb.notNil });

	SynthDef('spectral-comb' ++ ~clean.numChannels, { |out, comb|
		var signal, chain, teeth = 256;
		var amount = comb.abs.clip(0.0, 1.0);
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_RectComb(chain, numTeeth: teeth * amount, width: 1 - amount));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral smear
	~clean.addModule(\smr, { |cleanEvent|
		cleanEvent.sendSynth('spectral-smear' ++ ~clean.numChannels,
			[
				smear: ~smr,
				out: ~out
			]
		)
	}, { ~smr.notNil });

	SynthDef('spectral-smear' ++ ~clean.numChannels, { |out, smear|
		var signal, chain;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_MagSmear(chain, bins: smear.linexp(0.0,1.0,1,64)));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral scramble
	~clean.addModule(\scm, { |cleanEvent|
		cleanEvent.sendSynth('spectral-scram' ++ ~clean.numChannels,
			[
				scram: ~scm,
				out: ~out
			]
		)
	}, { ~scm.notNil });

	SynthDef('spectral-scram' ++ ~clean.numChannels, { |out, scram|
		var signal, chain;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BinScramble(chain, wipe: scram, width: scram));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral binshift
	~clean.addModule(\sbs, { |cleanEvent|
		cleanEvent.sendSynth('spectral-binshift' ++ ~clean.numChannels,
			[
				binshift: ~sbs,
				out: ~out
			]
		)
	}, { ~sbs.notNil });

	SynthDef('spectral-binshift' ++ ~clean.numChannels, { |out, binshift|
		var signal, chain;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BinShift(chain, stretch: binshift.linlin(0.0, 1.0, 0.01, 4.0),
			shift: binshift * 10, interp: 1));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral high pass filter
	~clean.addModule(\hbr, { |cleanEvent|
		cleanEvent.sendSynth('spectral-hbrick' ++ ~clean.numChannels,
			[
				hbrick: ~hbr,
				out: ~out
			]
		)
	}, { ~hbrick.notNil });

	SynthDef('spectral-hbrick' ++ ~clean.numChannels, { |out, hbrick|
		var signal, chain;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BrickWall(chain, wipe: hbrick * 0.6)); // Signal almost disappears around 0.5 therefore it's scaled a bit
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral low pass filter
	~clean.addModule(\lbr, { |cleanEvent|
		cleanEvent.sendSynth('spectral-lbrick' ++ ~clean.numChannels,
			[
				lbrick: ~lbr,
				out: ~out
			]
		)
	}, { ~lbrick.notNil });

	SynthDef('spectral-lbrick' ++ ~clean.numChannels, { |out, lbrick|
		var signal, chain;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		// lbrick parameter scaled to negative range to activate lopass filter (see ugen help file)
		signal = IFFT(PV_BrickWall(chain, wipe: lbrick.linlin(0.0,1.0,0.0,(-1.0))));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Conformer
	~clean.addModule(\scf, { |cleanEvent|
		cleanEvent.sendSynth('spectral-conformer' ++ ~clean.numChannels,
			[
				real: ~scf,
				imag: ~img,
				out: ~out
			]
		)
	}, { ~ral.notNil or: ~img.notNil });

	SynthDef('spectral-conformer' ++ ~clean.numChannels, { |out, real = 0.5, imag = 0.5|
		var signal, chain;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(
			PV_ConformalMap(chain, real.linlin(0.0, 1.0, 0.01, 2.0), imag.linlin(0.00, 1.0, 0.01, 10.0))
		).tanh;
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	// Enhance
	~clean.addModule(\enh, { |cleanEvent|
		cleanEvent.sendSynth('spectral-enhance' ++ ~clean.numChannels,
			[
				enhance: ~enh,
				out: ~out
			]
		)
	}, { ~enh.notNil });

	SynthDef('spectral-enhance' ++ ~clean.numChannels, { |out, enhance = 0.5|
		var signal, chain;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(
			PV_SpectralEnhance(chain,
				enhance.linlin(0.0, 1.0, 1, 16),
				enhance.linlin(0.0, 1.0, 1.0, 5.0),
				enhance.linlin(0.0, 1.0, 0.0, 0.99))
		).tanh; // .tanh is used as a crude limiter here beacause sometimes this ugen goes crazy
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral Phase Decorrelator.
	// Made by Boris Klompus.
	// Activate it by providing the \psd or \psb key a value in a pattern.
	// Parameters:
	// psd | psa | psi | pso | psb
	(
		SynthDef(\clean_spectralPhaseDecorrelator, {
			var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(0.5).linlin(0.0, 1.0, -1.0, 1.0),
			depth = \depth.kr(0.1).linlin(0.0, 1.0, 0, 2pi), accumulate = \accumulate.kr;
			var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
			var numFrames = 2048;
			signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
			signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
			signal[1] = IFFT(PV_PhaseShift(signal[1], [depth, depth.linlin(0, 2pi, 2pi, 0)], accumulate));
			signal[1] = XFade2.ar(signal[0], signal[1], blend);
			signal[1] = signal[1] * outputGain;
			ReplaceOut.ar(bus, signal[1])
		}).add;

		~clean.addModule(\psd, { |cleanEvent|
			cleanEvent.sendSynth(\clean_spectralPhaseDecorrelator, [
				depth: ~psd ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\depth].defaultValue },
				accumulate: ~psa ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\accumulate].defaultValue },
				inputGain: ~psi ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\inputGain].defaultValue },
				outputGain: ~pso ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\outputGain].defaultValue },
				blend: ~psb ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\blend].defaultValue },
				bus: ~out
			])
		}, { ~psd.notNil or: ~psb.notNil });

		// presetStore.(\psd);
	);

	// A low pass filter for the first half of the range, and a high pass for the rest.
	~clean.addModule(\lhf, { |cleanEvent|
		cleanEvent.sendSynth('lhf-filter' ++ ~clean.numChannels,
			[
				lhf: ~lhf,
				out: ~out
			]
	)}, { ~lhf.notNil});

	SynthDef('lhf-filter' ++ ~clean.numChannels, { |out, lhf|
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


		~clean.addModule(\flp,
			{ |cleanEvent|
				cleanEvent.sendSynth(\clean_channel_flip ++ numChannels,
					[
						flp: ~flp,
						out: ~out
				])

		}, { ~flp.notNil and: { ~flp != 0.0 } });

		SynthDef(\clean_channel_flip ++ numChannels, { |out=0|
			var sig = In.ar(out, numChannels).reverse;
			ReplaceOut.ar(out, sig)
		}, #[\ir]).add;


	~clean.addModule(\brf,
		{ |cleanEvent|
			cleanEvent.sendSynth(\clean_brf ++ numChannels,
				[
					bandrf: ~brf,
					bandrq: ~brq,
					numbrf: ~brn ?? { 1 },
					offset: ~bro,
					out: ~out
			])

	}, { ~brf.notNil });

	SynthDef(\clean_brf ++ numChannels, { |out, bandrf = 440, bandrq = 1.0, numbrf = 1, offset = 0|

		var signal = In.ar(out, numChannels);
		bandrq = bandrq.clip(0.0, 1.0);
		numbrf = numbrf.clip(0.0, 1.0);

		// numbrf = 0, no BRFs; numbrf = 0.1, 1 BRF; numbrf = 0.2, 2 BRFs .. numbrf = 1.0, 10 BRFs
		signal = Select.ar(numbrf.linlin(0.0, 0.1, 0, 1), [
			signal,
			BRF.ar(signal, bandrf.clip(20, 20000), bandrq)
		]);
		signal = Select.ar(numbrf.linlin(0.1, 0.2, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 4.midiratio)).clip(20, 20000), bandrq) // offset up to 1/3 octave per BRF
		]);
		signal = Select.ar(numbrf.linlin(0.2, 0.3, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 8.midiratio)).clip(20, 20000), bandrq)
		]);
		signal = Select.ar(numbrf.linlin(0.3, 0.4, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 12.midiratio)).clip(20, 20000), bandrq)
		]);
		signal = Select.ar(numbrf.linlin(0.4, 0.5, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 16.midiratio)).clip(20, 20000), bandrq)
		]);
		signal = Select.ar(numbrf.linlin(0.5, 0.6, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 20.midiratio)).clip(20, 20000), bandrq)
		]);
		signal = Select.ar(numbrf.linlin(0.6, 0.7, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 24.midiratio)).clip(20, 20000), bandrq)
		]);
		signal = Select.ar(numbrf.linlin(0.7, 0.8, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 28.midiratio)).clip(20, 20000), bandrq)
		]);
		signal = Select.ar(numbrf.linlin(0.8, 0.9, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 32.midiratio)).clip(20, 20000), bandrq)
		]);
		signal = Select.ar(numbrf.linlin(0.9, 1.0, 0, 1), [
			signal,
			BRF.ar(signal, ((bandrf * (offset <= 0)) + ((offset <= 0)) + ((offset > 0) * bandrf * offset * 36.midiratio)).clip(20, 20000), bandrq)
		]);

		ReplaceOut.ar(out, signal)
	}, [\ir]).add;

}.value
)