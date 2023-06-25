// an example using fmx which is the built in four operator FM synthesizer,
// deterministic operations, indefinite duration
(
Pdef(0,
	Pseed(4,
		Pbind(*[
			type: \cln,
			snd: \fmx,
			dup: Pexprand(9, 99),
			hr1: Pdup(Pkey(\dup) - Pwhite(0, 7), Pshuf((1 .. 4), inf)),
			hr2: Pdup(Pkey(\dup) + Pwhite(0, 7), Pshuf((1 .. 4), inf)),
			hr3: Pdup(Pkey(\dup) - Pwhite(0, 7), Pshuf((1 .. 4), inf)),
			hr4: Pdup(Pkey(\dup) + Pwhite(0, 7), Pshuf((1 .. 4), inf)),
			fdb: Pexprand(0.0001, 100.0),
			mi2: Pdup(Pkey(\dup) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
			mi3: Pdup(Pkey(\dup) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
			mi4: Pdup(Pkey(\dup) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
			amp: Pexprand(0.3, 0.8),
			en1: Pdup(Pkey(\dup) + Pwhite(0, 7), Pexprand(0.0001, 0.555)),
			en2: Pdup(Pkey(\dup) + Pwhite(0, 7), Pkey(\en1) * Pexprand(0.2, 0.666)),
			en3: Pdup(Pkey(\dup) + Pwhite(0, 7), Pkey(\en1) * Pkey(\en2) / Pexprand(0.3, 0.777)),
			en4: Pdup(Pkey(\dup) + Pwhite(0, 7), Pkey(\en1) * Pkey(\en2) / Pkey(\en3) * Pexprand(0.4, 0.888)),
			cu1: Pdup(Pkey(\dup) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
			cu2: Pdup(Pkey(\dup) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
			cu3: Pdup(Pkey(\dup) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
			cu4: Pdup(Pkey(\dup) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
			dur: Pdup(Pkey(\dup) + Pwhite(2, 9), 2 / Pbrown(5, 19, Pwhite(1, 3), inf)),
			legato: Pkey(\dur) * Pexprand(16, 64),
			freq: (Pdup(Pexprand(4, 32), 10 * Pexprand(1, 5).round)
				* Pdup(Pexprand(1, 64), Pexprand(1, 5)).round
				* Pdup(Pkey(\dup), Pexprand(1, 7).round)),
			cav: 1,
			ca1: Pseg(Pexprand(0.25, 1.0), Pexprand(8.0, 64.0), \welch, inf),
			pan: Pbrown(0.0, 1.0, Pdup(Pwhite(1, 3), Pwhite(0.01, 0.1))).trace,
			atk: Pexprand(0.01, 4.0),
			hld: Pkey(\dur) * 2,
			rel: Pkey(\dur) * 2,
			crv: 5,
			sustain: Pexprand(2.5, 5.0),
		])
	)
).play
)

// an example of using the sampler, looks for samples in a folder called mmd
// deterministic operations, finite duration
(
Pdef(0,
	Pseed(Pn(999,1),
		Psync(
			Pbind(*[
				type: \cln,
				snd: \mmd,
				num: Pwhite(0, 23),
				dur: Pwrand([1/12, 1/3], [9, 1].normalizeSum, inf),
				rel: Pdup(Pwhite(1, 8), Pseq([1/16, 1/17, 1/18, 1/19, 1/20, 1/21, 1/22, 1/8, 2], inf)) * Pexprand(0.1, 10.0),
				amp: Pexprand(1.0, 8.0),
				pan: Pdup(Pwhite(0, 28), Pwrand([Pwhite(0.0, 0.333), Pwhite(0.666, 1.0)], [1, 1.5].normalizeSum, inf)),
				lpf: Pwrand([625, 1250, 2500, 5000, 10000, 20000], (1 .. 6).normalizeSum, inf),
				spd: Pwrand([
                    1/64, 1/32, 1/16, 1/8, 1/4, 1/2, 1, 2, 4, 8, 16, 32, 64],
                    [1, 2, 4, 8, 16, 32, 64, 32, 16, 8, 4,  2, 1].normalizeSum,inf),
				shp: Pwhite(0.0, 1.0).trace,
				dla: 0.001,
				dlf: 0.94,
				dlt: 1/2 / Pdup(Pwrand([1, 2, 3], [256, 16, 1].normalizeSum,inf), Pbrown(1, 199, Prand((1 .. 19), inf))),
				rin: Pwrand([0,0.05], [9, 1].normalizeSum, inf),
				rev: 0.97,
				dry: Pdup(Pwhite(1, 9), Pwrand([0.25, 1], [3, 1].normalizeSum, inf)),
				hpf: 40,
			]), 1, 15,
		)
	)
).play
)

// an example using add which is the built in additive synthesizer
// stochastic operations, indefinite duration
(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \add,
		amp: Pseg(Pexprand(0.4, 0.7), Pexprand(0.4, 4.0), \exp, inf),
		freq: Pfunc{
			var x = 40 * (1 .. 7).choose * rrand(1, 250).geom(1, 30/29);
			x.reject{|i| i > 20000 }
		}.trace,
		dur: Pdup(Pexprand(5, 11), Pexprand(1, 3).round / Pexprand(5, 15).round),
		ada: Pexprand(0.00000000000000000000000000000000000000000000001, 10.1),
		adr: Pkey(\dur) + (Pexprand(0.000001, 10.0)),
		hpf: Pseg(Pexprand(40, 4000), Pexprand(0.001, 10.0), \exp, inf),
		adc: Pexprand(-8.0, -0.0001),
		slw: Pexprand(0.00001, 10.0),
		pan: Pseg(Pwhite(0.1, 0.9), Pwhite(1.0, 10.0), \exp, inf),
		legato: Pexprand(0.25, 1.25),
		sustain: Pexprand(0.25, 1.25),
		stretch: Pseg(Pexprand(0.75, 1.25), Pexprand(0.5, 8.0), \exp, inf),
	])
).play
)


// an example using sin, saw and sqr which are the built in basic waveform synthesizers
// stochastic operations, indefinite duration
(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: Pxrand([\sin, \saw, \sqr, \r], inf),
		dur: 1 / Pdup(Pwhite(5, 11), Pwhite(5, 11), inf),
		sustain: Pdup(Pwhite(5, 11), Pwhite(3.0, 9.0), inf),
		atk: Pdup(Pwhite(5, 11), Pexprand(0.001, 10.0), inf),
		hld: Pdup(Pwhite(5, 11), Pwhite(3.0, 5.0), inf),
		rel: Pdup(Pwhite(5, 11), Pwhite(5.0, 11.0), inf),
		crv: -8,
		amp: Pseg(Pexprand(0.5, 0.9), Pexprand(0.25, 4.0), \exp, inf),
		pan: Pwhite(0.0, 1.0),
		wid: Pwhite(0.0, 1.0),
		iph: Pexprand(0.0001, 1.0),
		lpf: Pexprand(20, 20000),
		stretch: Pseg([1/6, 7, 1/6], 16, \exp, inf).trace,
		midinote: 60 + Pdup(Pwhite(5, 11), Pxrand((-24, Pdup(Pwhite(1, 100), Prand([-9, -10], inf)) .. 24), inf)),
		legato: Pkey(\atk) + Pkey(\hld) + Pkey(\rel) + Pkey(\sustain),
	])
).play
)

// an example using drm which is the built in drum synthesizer
// stochastic operations, indefinite duration
(
Pdef(0,
	Pbind(*[
		type: Pwrand([\cln, \r], [6, 1].normalizeSum, inf),
		snd: \drm,
		dur: 1 / Pwrand([5, 10], [3, 8].normalizeSum, inf),
		tun: Pdup(Pexprand(1, 8), Pexprand(0.0001, 0.25)).trace,
		fed: Pexprand(0.00001, 2000.0),
		dst: Pwhite(0.0, 1.0),
		shp: Pwhite(0.0, 1.0),
		sac: Pwhite(0.0, 1.0),
		slo: Pwhite(0.0, 1.0),
		shi: Pwhite(0.0, 1.0),
		sho: Pwhite(0.0, 1.0),
		lot: Pwhite(0.0, 1.0),
		hit: Pwhite(0.0, 1.0),
		tri: Pwhite(0.0, 1.0),
		amp: Pdup(Pexprand(1, 5), Pexprand(0.75, 2.0)),
		rel: Pexprand(Pkey(\dur) / (4/3), Pkey(\dur) * 64),
		crv: Pmeanrand(-8.0, 8.0),
		pan: Pdup(Pexprand(1, 7), Pseq([0.5, 0.75, 1.0, 0.75, 0.5, 0.25, 0.0, 0.25], inf)),
		lpf: 20000 - Pexprand(2000, 20000),
		sustain: Pdup(Pexprand(1, 3), Pexprand(0.1, 2.0)),
		legato: Pwrand([Pkey(\dur) * 1.5, Pkey(\dur) * 16], [1, 2].normalizeSum, inf),
	])
).play
)

( // an example using kps which is a Karplus-Strong physical model of a vibrating string
// stochastic operations, indefinite duration
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \kps,
		amp: Pexprand(0.5, 1.0),
		freq: 32 * Prand([1, 2, 4, 8, 16], inf) * (1, 3 .. 11),
		dur: 1 / Pdup(Pwhite(5, 11), Pwhite(5, 11)),
		sustain: Pexprand(0.5, 4.0),
		hpf: Pexprand(20, 20000),
		lpf: (20000 - Pexprand(20, 20000)).trace,
		pan: Pwhite(0.0, 1.0),
	])
).play
)

( // an example using hat which is a tunable noise source and a filter
// stochastic operations, indefinite duration
Pdef(0,
	Pbind(*[
		type: Pwrand([\cln, \r], [12, 1].normalizeSum, inf),
		snd: \hat,
		amp: Pwrand([0.85, 1.6], [12, 1].normalizeSum, inf),
		sustain: Pwrand([1/11, 2], [27, 1].normalizeSum, inf),
		dur: 1 / Pwrand([8, 4], [12, 1].normalizeSum, inf),
		bnd: (3 - Pexprand(1.0, 3.0) - 1),
		tun: Pwrand([-2, 4], [12, 1].normalizeSum, inf),
		dst: Pwrand([0, 1], [12, 1].normalizeSum, inf),
		shp: Pseg([0.0, 0.8, 0.0], Pexprand(4.0, 12), \sine, inf),
		tri: Pseg([0.0, 0.0, 9.0], Pexprand(4.0, 12), \sine, inf),
		lpf: Pseg([20000, 400, 20000], Pexprand(4.0, 18), \sine, inf),
		pan: Pseg([0.5, 0,1, 0.5], Pexprand(4.0, 12), \sine, inf),
		dla: Pseg([0.0, 1/20, 0.0], Pexprand(8.0, 36), \sine, inf),
		dlf: 0.94,
		dlt: (2 / Pdup(Pn(Pgeom(1, 2, 3), inf), Pn(Pgeom(1, 2, 11), inf))).trace,
		stretch: 0.7,
	])
).play
)

( // an example using dfd which is a transient / noise excited filter that can selfoscillate
Pdef(0, // deterministic operations, indefinite duration
	Pseed(192,
		Pbind(*[
			type: \cln,
			snd: \dfd,
			amp: Pseg(Pexprand(0.25, 1.0), Pwhite(5.0, 10.0), \exp, inf),
			rel: Phprand(0.0, 4.0),
			freq: 80 * Plprand(1, 13),
			sustain: 8,
			legato: 8,
			res: Pseg(Pexprand(0.9725, 1.01), Pwhite(5.0, 10.0), \exp, inf).trace,
			dur: 1/8,
			stretch: Pseg([1, 4, 1, 0.75, 1], [10, 5, 10], \sin, inf),
		])
	)
).play
)

// an example using bow which is a digital wave guide physical model of a bowed instrument
( // deterministic operations, indefinite duration
var a = Pwhite(0.0, 0.25).asStream;
var b = Pwhite(0.75, 1.0).asStream;
Pdef(0,
	Pseed(253,
		Pbind(*[
			type: \cln,
			snd: \bow,
			frc: Pexprand(0.1, 1.0),
			pos: Pexprand(0.07, 0.7),
			octave: Pdup(Pexprand(1, 5), Pxrand((1 .. 6), inf)),
			scale: Scale.aeolian.tuning_(Tuning.vallotti),
			degree: Pdup(Pexprand(1, 5), Pxrand((0 .. 7), inf)),
			mtranpose: Pdup(Pexprand(1, 5), Pxrand((-11 .. 3), inf)),
			amp: Pdup(2, Pexprand(0.555, 0.66666 / Pkey(\octave).linexp(1, 6, 0.9, 2))),
			atk: Pexprand(1.0, 15.0) - 1,
			hld: Pwhite(0.5, 4.0),
			rel: Pwhite(5.0, 10.0),
			crv: Pwhite(0.0, 8.0) - Prand([0, 8], inf),
			sustain: Pexprand(29.0, 80.0),
			legato: Pexprand(29.0, 80.0),
			pan: Pseq([Pfuncn({ a.next }, 1), Pfuncn({ b.next }, 1)], inf).trace,
			lhf: Pexprand(0.25, 0.75),
			bpr: Pseg([1, 1/256], Pwhite(30, 90), \sine, inf),
			dur: 1 / Pwrand([1/4, 1/2, 1, 2, 4, 5, 7, 8], [4, 6, 1, 8, 4, 5, 1/2, 2].normalizeSum, inf),
			dla: 1/64,
			dlf: 0,
			dlt: 16,
			cav: 1/8,
			hal: 1/16,
			rts: Pseg([0, 64, 0], Pwhite(30, 90), \sine, inf),
		])
	)
).play
)

( // an example using ixa which is a cpu efficient cousin of FM synthesis with a meandering feel
Routine{ // deterministic operations, finite duration, music in parts
    Pdef(0,
        Pseed(1,
            Pbind(*[
                type: \cln,
                snd: \ixa,
                rel: 1/2,
                crv: -8.0,
                crt: 8.0,
                inx: (Pseries(0, 1, inf) % Pdup(Pseq((1 .. 21), inf), Pseq((1 .. 22), inf))),
                scale: Scale.harmonicMinor(\just),
                degree: Pindex((1 .. 22), Pkey(\inx), inf),
                lpf: Pkey(\degree).linexp(1, 22, 2500, 160),
                lhf: Pkey(\degree).linexp(1, 22, 0.5, 0.3),
                dur: 1/9,
                amp: Pkey(\degree).linlin(1, 22, 0.5, 1.0) - Pseq((0.0, 0.005 .. 0.045), inf),
                pan: Pseq([0.5, Plprand(0.0, 0.75, 1), Phprand(0.25, 1.0, 1)], inf),
                legato: 19,
                cav: 1/4,
                cai: Pkey(\degree).explin(7, 22, 0.0, 1.0),
                octave: 4,
                mtranspose: (Pseries(0, 1, inf) % Pdup(Pseq((2 .. 9), inf), Pseq((-1 .. -8), inf))),
                stretch: 0.9,
                aux: 1,
            ])
        )
    ).play;
    9.wait;
    Pdef(1,
        Pseed(9,
            Pbind(*[
                type: \cln,
                snd: \ixa,
                atk: 4,
                hld: Plprand(0.0, 8.0).trace,
                rel: 1/4,
                inx: (Pseries(0, 1, inf) % Pdup(Pseq((1 .. 45), inf), Pseq((1 .. 45), inf))),
                scale: Scale.harmonicMinor(\just),
                degree: Pindex((0 .. 44), Pkey(\inx), inf),
                lpf: Pkey(\degree).linlin(0, 45, 2500, 20),
                lhf: Pkey(\degree).linlin(0, 45, 0.4, 0.0),
                dur: 1/8,
                pan: Pwhite(0.0, 1.0),
                legato: 99,
                cav: 1/4,
            ])
        )
    ).play;
    15.wait;
    Pdef(0).stop;
    9.wait;
    Pdef(1).stop;
}.play
)

// please be advised; This last example is very LOUD!
( // an example of using the dfm stereo distortion on a couple of different instruments,
Pdef(0, // deterministic operations, indefinite duration
	Pseed(66, // 666666666,
		Pbind(*[
			type: \cln,
			snd: Prand([\dfd, \drm, \kps, \ixa, \sin, \bow], inf),
			dur: Plprand(0.1, 1.0),
			amp: Plprand(0.125, 1.0),
			pan: Pwhite(0.0, 1.0),
			freq: Plprand(40, 240).round(40),
			freq: Pdup(Plprand(19, 29), Prand([50, 60, 80, 90, 110], inf)) * [1, 3/2],
			tun: Plprand(0.0, 8.0).round(1/4),
			lpf: Plprand(20, 20000),
			dfm: 1,
			dfg: Pseg(Pdup(2, Plprand(0.0, 999.0)), Pwhite(1.0, 9.0), \lin, inf).trace,
			atk: 3,
			hld: 3,
			rel: 3,
			crv: 4.0,
			crt: -4.0,
			legato: 99,
		])
	)
).play
)