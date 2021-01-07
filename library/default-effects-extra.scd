/*

DEFAULT EFFECTS EXTRA

*/
(
	// Waveloss
	// Divides an audio stream into tiny segments, using the signal's
	// zero-crossings as segment boundaries, and discards a fraction of them.

	~clean.addModule('waveloss', { |cleanEvent|
		cleanEvent.sendSynth('waveloss' ++ ~clean.numChannels,
			[
				drop: ~wls,
				out: ~out
			]
		)
	}, { ~wls.notNil });

	SynthDef("waveloss" ++ ~clean.numChannels, { |out, drop = 1|
		var sig = In.ar(out, ~clean.numChannels);
		sig = WaveLoss.ar(sig, drop, outof: 100, mode: 2);
		ReplaceOut.ar(out, sig)
	},[\ir, \ir]).add;

	// Squiz
	// "reminiscent of some weird mixture of filter, ring-modulator
	// and pitch-shifter"
	~clean.addModule('squiz', { |cleanEvent|
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
	~clean.addModule('frequencyshifter', { |cleanEvent|
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
	~clean.addModule('triode', { |cleanEvent|
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
	~clean.addModule('octer', { |cleanEvent|
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

// Ring modulation with `rma` (modulation wet), `rmf` (modulation frequency), `rdf` (the frequency to glissando in from) and `rdt` (the glissando time)
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
	~clean.addModule('spectral-delay', { |cleanEvent|
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
	~clean.addModule('spectral-freeze', { |cleanEvent|
		cleanEvent.sendSynth('spectral-freeze' ++ ~clean.numChannels,
			[
				freeze: ~frz,
				out: ~out
			]
		)
	}, { ~frz.notNil } );


	/*SynthDef("spectral-freeze" ++ ~clean.numChannels, { |out, freeze| // broken, I dunno, untoggle and use at own risk, values seem to be 0 for off and 1 for on
		var signal, chain, in;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_Freeze(chain, freeze));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral comb
	~clean.addModule('spectral-comb', { |cleanEvent|
		cleanEvent.sendSynth('spectral-comb' ++ ~clean.numChannels,
			[
				comb: ~cmb,
				out: ~out
			]
		)
	}, { ~cmb.notNil });*/

	SynthDef("spectral-comb" ++ ~clean.numChannels, { |out, comb|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
	signal = IFFT(PV_RectComb(chain, numTeeth: teeth * comb.abs.clip(0.0, 1.0), width: 1-comb.abs.clip(0.0, 1.0)));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral smear
	~clean.addModule('spectral-smear', { |cleanEvent|
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
	~clean.addModule('spectral-scram', { |cleanEvent|
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
	~clean.addModule('spectral-binshift', { |cleanEvent|
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
	~clean.addModule('spectral-hbrick', { |cleanEvent|
		cleanEvent.sendSynth('spectral-hbrick' ++ ~clean.numChannels,
			[
				hbrick: ~hbrick,
				out: ~out
			]
		)
	}, { ~hbrick.notNil });


	SynthDef("spectral-hbrick" ++ ~clean.numChannels, { |out, hbrick|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~clean.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BrickWall(chain, wipe: hbrick * 0.6)); // Signal almost disappears around 0.5 therefore it's scaled a bit
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral low pass filter
	~clean.addModule('spectral-lbrick', { |cleanEvent|
		cleanEvent.sendSynth('spectral-lbrick' ++ ~clean.numChannels,
			[
				lbrick: ~lbrick,
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
	~clean.addModule('spectral-conformer', { |cleanEvent|
		cleanEvent.sendSynth('spectral-conformer' ++ ~clean.numChannels,
			[
				real: ~ral,
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
	~clean.addModule('spectral-enhance', { |cleanEvent|
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
	~clean.addModule('dj-filter', { |cleanEvent|
		cleanEvent.sendSynth('dj-filter' ++ ~clean.numChannels,
		// OPTIONAL
		// passing this array of parameters could be left out,
		// but it makes it clear what happens
		[
			djf: ~lhf,
			out: ~out
		]
	)}, { ~lhf.notNil});

	SynthDef("dj-filter" ++ ~clean.numChannels, { |out, djf|
		var signal;
		var lpfCutoffFreq = djf.linexp(0, 0.5, 20, 10000);
		var hpfCutoffFreq = djf.linexp(0.5, 1, 20, 10000);

		signal = In.ar(out, ~clean.numChannels);

		signal = RHPF.ar(
			RLPF.ar(
				signal,
				lpfCutoffFreq
			),
			hpfCutoffFreq
		);
		ReplaceOut.ar(out, signal)
	}).add;
)
