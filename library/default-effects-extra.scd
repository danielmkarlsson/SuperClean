/*

DEFAULT EFFECTS EXTRA

*/
(
	// Waveloss
	// Divides an audio stream into tiny segments, using the signal's
	// zero-crossings as segment boundaries, and discards a fraction of them.

	~cln.addModule('waveloss', { |cleanEvent|
		cleanEvent.sendSynth('waveloss' ++ ~cln.numChannels,
			[
				drop: ~waveloss,
				out: ~out
			]
		)
	}, { ~waveloss.notNil });

	SynthDef("waveloss" ++ ~cln.numChannels, { |out, drop = 1|
		var sig = In.ar(out, ~cln.numChannels);
		sig = WaveLoss.ar(sig, drop, outof: 100, mode: 2);
		ReplaceOut.ar(out, sig)
	},[\ir, \ir]).add;

	// Squiz
	// "reminiscent of some weird mixture of filter, ring-modulator
	// and pitch-shifter"
	~cln.addModule('squiz', { |cleanEvent|
		cleanEvent.sendSynth('squiz' ++ ~cln.numChannels,
			[
				pitchratio: ~squiz,
				out: ~out
			]
		)
	}, { ~squiz.notNil });

	SynthDef("squiz" ++ ~cln.numChannels, { |out, pitchratio = 1|
		var sig = In.ar(out, ~cln.numChannels);
		sig = Squiz.ar(sig, pitchratio);
		ReplaceOut.ar(out, sig)
	}, [\ir, \ir]).add;

	// Frequency shifter
	// Total shift is sum of `fshift` (in Hz) and `fshiftnote` times the current note frequency.
	// `fshiftphase` allows control over the phase
	~cln.addModule('fshift', { |cleanEvent|
		cleanEvent.sendSynth("clean_fshift" ++ ~cln.numChannels,
			[
				fshift: ~fshift,
				fshiftphase: ~fshiftphase,
				fshiftnote: ~fshiftnote,
				freq: ~freq,
				out: ~out
			]
		)
	}, { ~fshift.notNil });

	SynthDef("clean_fshift" ++ ~cln.numChannels, { |out, fshift, fshiftphase, fshiftnote, freq|
		var sig = In.ar(out, ~cln.numChannels);
		var shift = freq * fshiftnote + fshift;
		sig = FreqShift.ar(sig, shift, fshiftphase);
		ReplaceOut.ar(out, sig);
	}, [\ir, \ir, \ir, \ir, \ir]).add;

	// Triode-like distortion, uses only the `triode` parameter
	~cln.addModule('triode', { |cleanEvent|
		cleanEvent.sendSynth("clean_triode" ++ ~cln.numChannels,
			[
				triode: ~triode,
				out: ~out
			]
		)
	}, { ~triode.notNil });

	SynthDef("clean_triode" ++ ~cln.numChannels, { |out, triode|
		var sig, sc;
		sig = In.ar(out, ~cln.numChannels);
		sc = triode * 10 + 1e-3;
		sig = (sig * (sig > 0)) + (tanh(sig * sc) / sc * (sig < 0));
		ReplaceOut.ar(out, LeakDC.ar(sig));
	}, [\ir, \ir]).add;

	// Sonic Pi's krush
	// modified a bit so krush "0" is the same as dry signal
	// uses `krush` and `kcutoff` as paramters
	~cln.addModule('krush', { |cleanEvent|
		cleanEvent.sendSynth("clean_krush" ++ ~cln.numChannels,
			[
				krush: ~krush,
				kcutoff: ~kcutoff,
				out: ~out
			]
		)
	}, { ~krush.notNil });

	SynthDef("clean_krush" ++ ~cln.numChannels, { |out, krush, kcutoff|
		var orig, signal, freq;
		freq = Select.kr(kcutoff > 0, [DC.kr(4000), kcutoff]);
		orig = In.ar(out, ~cln.numChannels);
		signal = (orig.squared + (krush * orig)) / (orig.squared + (orig.abs * (krush-1.0)) + 1.0);
		signal = RLPF.ar(signal, clip(freq, 20, 10000), 1);
		signal = SelectX.ar(krush * 2.0, [orig, signal]);
		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir]).add;

	// Sonic Pi's octaver
	// uses `octer` for octave harmonics, `octersub` for half-frequency harmonics, and `octersubsub` for
	// quarter-frequency harmonics
	~cln.addModule('octer', { |cleanEvent|
		cleanEvent.sendSynth("clean_octer" ++ ~cln.numChannels,
			[
				octer: ~octer,
				octersub: ~octersub,
				octersubsub: ~octersubsub,
				out: ~out
			]
		)
	}, { ~octer.notNil or: { ~octersub.notNil } or: { ~octersubsub.notNil }});

	SynthDef("clean_octer" ++ ~cln.numChannels, { |out, octer, octersub, octersubsub|
		var signal, oct1, oct2, oct3, sub;
		signal = In.ar(out, ~cln.numChannels);
		oct1 = 2.0 * LeakDC.ar( abs(signal) );
		sub = LPF.ar(signal, 440);
		oct2 = ToggleFF.ar(sub);
		oct3 = ToggleFF.ar(oct2);
		signal = SelectX.ar(octer, [signal, octer * oct1, DC.ar(0)]);
		signal = signal + (octersub * oct2 * sub) + (octersubsub * oct3 * sub);
		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir, \ir]).add;

	// Ring modulation with `ring` (modulation amount), `ringf` (modulation frequency), and `ringdf` (slide
	// in modulation frequency)
	~cln.addModule('rma', { |cleanEvent|
		cleanEvent.sendSynth("clean_rma" ++ ~cln.numChannels,
			[
				rma: ~rma,
				rmf: ~rmf,
				rdf: ~rdf,
			    rdt: ~rdt,
				out: ~out
			]
		)
	}, { ~rma.notNil });

	SynthDef("clean_rma" ++ ~cln.numChannels, { |out, rma = 0, rmf = 0, rdf, rdt = 0.5|
		var signal, mod;
		signal = In.ar(out, ~cln.numChannels);
		mod = rma * SinOsc.ar(Clip.kr(XLine.kr(rmf, rdf, rdt), 20, 20000));
		signal = ring1(signal, mod); // Looks confusing huh? Well ring1 as it turns out is an operator, check the docs, and has nothing to do with the args
		ReplaceOut.ar(out, signal);
	}, [\ir, \ir, \ir, \ir]).add;

	// A crunchy distortion with a lot of high harmonics, the only parameter is `distort`
	~cln.addModule('distort', { |cleanEvent|
		cleanEvent.sendSynth("clean_distort" ++ ~cln.numChannels,
			[
				distort: ~distort,
				out: ~out
			]
		)
	}, { ~distort.notNil });

	SynthDef("clean_distort" ++ ~cln.numChannels, { |out, distort = 0|
		var signal, mod;
		signal = In.ar(out, ~cln.numChannels);
		mod = CrossoverDistortion.ar(signal, amp: 0.2, smooth: 0.01);
		mod = mod + (0.1 * distort * DynKlank.ar(`[[60,61,240,3000 + SinOsc.ar(62,mul: 100)],nil,[0.1, 0.1, 0.05, 0.01]], signal));
		mod = (mod.cubed * 8).softclip * 0.5;
		mod = SelectX.ar(distort, [signal, mod]);
		ReplaceOut.ar(out, mod);
	}, [\ir, \ir]).add;

	// Spectral delay
	~cln.addModule('spectral-delay', { |cleanEvent|
		cleanEvent.sendSynth('spectral-delay' ++ ~cln.numChannels,
			// OPTIONAL
			// passing this array of parameters could be left out,
			// but it makes it clear what happens and it is also more
			// effecient to explicitly specify the arguments
			[
				xsdelay: ~xsdelay,
				tsdelay: ~tsdelay,
				out: ~out
			]
		)
	}, { ~tsdelay.notNil or: { ~xsdelay.notNil }});

	SynthDef("spectral-delay" ++ ~cln.numChannels, { |out, tsdelay = 0.5, xsdelay = 0.5|

		var signal, delayTime, delays, freqs, filtered;
		var size = 16;
		var maxDelayTime = 0.2;
		signal = In.ar(out, ~cln.numChannels);
		delayTime = tsdelay * maxDelayTime;
		filtered = (1..size).sum { |i|
			var filterFreq = i.linexp(1, size, 40, 17000);
			var sig = BPF.ar(signal, filterFreq, 0.005);
			// the delay pattern is determined from xsdelay by bitwise-and:
			DelayN.ar(sig, maxDelayTime, i & xsdelay * (1 / size) * delayTime )
		};
		signal = signal * 0.2 + (filtered * 4); // this controls wet / dry
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	// Spectral freeze
	~cln.addModule('spectral-freeze', { |cleanEvent|
		cleanEvent.sendSynth('spectral-freeze' ++ ~cln.numChannels,
			[
				freeze: ~freeze,
				out: ~out
			]
		)
	}, { ~freeze.notNil } );


	SynthDef("spectral-freeze" ++ ~cln.numChannels, { |out, freeze|
		var signal, chain, in;
		signal = In.ar(out, ~cln.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_Freeze(chain, freeze));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral comb
	~cln.addModule('spectral-comb', { |cleanEvent|
		cleanEvent.sendSynth('spectral-comb' ++ ~cln.numChannels,
			[
				comb: ~comb,
				out: ~out
			]
		)
	}, { ~comb.notNil });

	SynthDef("spectral-comb" ++ ~cln.numChannels, { |out, comb|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~cln.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_RectComb(chain, numTeeth: teeth * comb, width: 1-comb));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral smear
	~cln.addModule('spectral-smear', { |cleanEvent|
		cleanEvent.sendSynth('spectral-smear' ++ ~cln.numChannels,
			[
				smear: ~smear,
				out: ~out
			]
		)
	}, { ~smear.notNil });

	SynthDef("spectral-smear" ++ ~cln.numChannels, { |out, smear|
		var signal, chain, in;
		signal = In.ar(out, ~cln.numChannels);
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_MagSmear(chain, bins: smear.linexp(0.0,1.0,1,64)));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral scramble
	~cln.addModule('spectral-scram', { |cleanEvent|
		cleanEvent.sendSynth('spectral-scram' ++ ~cln.numChannels,
			[
				scram: ~scram,
				out: ~out
			]
		)
	}, { ~scram.notNil });

	SynthDef("spectral-scram" ++ ~cln.numChannels, { |out, scram|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~cln.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BinScramble(chain, wipe: scram, width: scram));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral binshift
	~cln.addModule('spectral-binshift', { |cleanEvent|
		cleanEvent.sendSynth('spectral-binshift' ++ ~cln.numChannels,
			[
				binshift: ~binshift,
				out: ~out
			]
		)
	}, { ~binshift.notNil });

	SynthDef("spectral-binshift" ++ ~cln.numChannels, { |out, binshift|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~cln.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BinShift(chain, stretch: binshift.linlin(0.0,1.0,0.01,4.0),
		shift: binshift * 10, interp: 1));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral high pass filter
	~cln.addModule('spectral-hbrick', { |cleanEvent|
		cleanEvent.sendSynth('spectral-hbrick' ++ ~cln.numChannels,
			[
				hbrick: ~hbrick,
				out: ~out
			]
		)
	}, { ~hbrick.notNil });


	SynthDef("spectral-hbrick" ++ ~cln.numChannels, { |out, hbrick|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~cln.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(PV_BrickWall(chain, wipe: hbrick * 0.6)); // Signal almost disappears around 0.5 therefore it's scaled a bit
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Spectral low pass filter
	~cln.addModule('spectral-lbrick', { |cleanEvent|
		cleanEvent.sendSynth('spectral-lbrick' ++ ~cln.numChannels,
			[
				lbrick: ~lbrick,
				out: ~out
			]
		)
	}, { ~lbrick.notNil });

	SynthDef("spectral-lbrick" ++ ~cln.numChannels, { |out, lbrick|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~cln.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		// lbrick parameter scaled to negative range to activate lopass filter (see ugen help file)
		signal = IFFT(PV_BrickWall(chain, wipe: lbrick.linlin(0.0,1.0,0.0,(-1.0))));
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir]).add;

	// Conformer
	~cln.addModule('spectral-conformer', { |cleanEvent|
		cleanEvent.sendSynth('spectral-conformer' ++ ~cln.numChannels,
			[
				real: ~real,
				imag: ~imag,
				out: ~out
			]
		)
	}, { ~real.notNil or: ~imag.notNil });

	SynthDef("spectral-conformer" ++ ~cln.numChannels, { |out, real = 0.5, imag = 0.5|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~cln.numChannels);
		clean = signal;
		chain = signal.asArray.collect { |x| FFT(LocalBuf(2048), x) };
		signal = IFFT(
				PV_ConformalMap(chain, real.linlin(0.0,1.0,0.01,2.0), imag.linlin(0.00,1.0,0.01,10.0))
			).tanh;
		ReplaceOut.ar(out, signal)
	}, [\ir, \ir, \ir]).add;

	// Enhance
	~cln.addModule('spectral-enhance', { |cleanEvent|
		cleanEvent.sendSynth('spectral-enhance' ++ ~cln.numChannels,
			[
				enhance: ~enhance,
				out: ~out
			]
		)
	}, { ~enhance.notNil });

	SynthDef("spectral-enhance" ++ ~cln.numChannels, { |out, enhance = 0.5|
		var signal, chain, in, clean, teeth = 256;
		signal = In.ar(out, ~cln.numChannels);
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



	// DJ filter, a low pass filter for the first half of the range, and a high pass for the rest.
	~cln.addModule('dj-filter', { |cleanEvent|
		cleanEvent.sendSynth('dj-filter' ++ ~cln.numChannels,
		// OPTIONAL
		// passing this array of parameters could be left out,
		// but it makes it clear what happens
		[
			djf: ~djf,
			out: ~out
		]
	)}, { ~djf.notNil});

	SynthDef("dj-filter" ++ ~cln.numChannels, { |out, djf|
		var signal;
		var lpfCutoffFreq = djf.linexp(0, 0.5, 20, 10000);
		var hpfCutoffFreq = djf.linexp(0.5, 1, 20, 10000);

		signal = In.ar(out, ~cln.numChannels);

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
