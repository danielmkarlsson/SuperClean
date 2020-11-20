// an example of using the sampler, looks for samples in a folder called mmd
(
Pdef(\0,
	Pseed(Pn(999,1),
		Psync(
			Pbind(*[
				type: \cln,
				snd: \mmd,
				num: Pwhite(0,23),
				dur: Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
				rel: Pstutter(Pwhite(1,8),Pseq([1/16,1/17,1/18,1/19,1/20,1/21,1/22,1/8,2],inf))*Pexprand(0.1,10.0),
				amp: Pexprand(1.0,8.0),
				pan: Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
				lpf: Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
				spd: Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
				shp: Pwhite(0.0,0.999).trace,
				dla: 0.001,
				dlf: 0.94,
				dlt: 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
				rin: Pwrand([0,0.05],[9,1].normalizeSum,inf),
				rev: 0.97,
				dry: Pstutter(Pwhite(1,9),Pwrand([0.25,1],[3,1].normalizeSum,inf)),
				hpf: 40,
			]),1,15,
		)
	)
).play(quant:1);
);

// an example using fmx which is the built in four operator FM synthesizer
(
Pdef(\0,
	Pseed(4,
		Pbind(*[
			type: \cln,
			snd: \fmx,
			rps: Pexprand(9,99),
			hr1: Pstutter(Pkey(\rps)-Pwhite(0,7),Pshuf((1..4),inf)),
			hr2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
			hr3: Pstutter(Pkey(\rps)-Pwhite(0,7),Pshuf((1..4),inf)),
			hr4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
			fdb: Pexprand(0.0001,100.0),
			mi2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			mi3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			mi4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			amp: Pexprand(0.25,0.75),
			en1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pexprand(0.0001,0.555)),
			en2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pexprand(0.2,0.666)),
			en3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pexprand(0.3,0.777)),
			en4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pkey(\en3)*Pexprand(0.4,0.888)),
			cu1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			dur: Pstutter(Pkey(\rps)+Pwhite(2,9),2/Pbrown(5,19,Pwhite(1,3),inf)),
			legato: Pkey(\dur)*Pexprand(16,64),
			freq: (Pstutter(Pexprand(4,32),10*Pexprand(1,5).round)
				*Pstutter(Pexprand(1,64),Pexprand(1,5)).round
				*Pstutter(Pkey(\rps),Pexprand(1,7).round)),
			dark: Pseg(Pexprand(0.25,1.0),Pexprand(8.0,64.0),\welch,inf),
			pan: Pbrown(0.0,1.0,Pstutter(Pwhite(1,3),Pwhite(0.01,0.1))).trace,
			atk: Pexprand(0.01,4.0),
			hld: Pkey(\dur)*2,
			rel: Pkey(\dur)*2,
			crv: 5,
			sustain: Pexprand(2.5,5.0),
		])
	)
).play(quant:1);
);

// an example using uio which is the built in additive synthesizer
(
Pdef(\0,
	Pbind(*[
		type: \cln,
		snd: \uio,
		amp: Pexprand(1/2,8.0),
		freq: Pfunc{
			var x = 160 * rrand(1,500).geom(1,30/29);
			x.reject{|i| i > 20000 }
		},
		dur: Pstutter(Pexprand(1,11).asInteger,Pexprand(1,3).round/Pexprand(5,29).round).trace,
		atk: Pexprand(0.0001,1.1),
		rel: Pkey(\dur)-(Pexprand(0.000001,0.01)),
		hpf: Pexprand(20,20000),
		crv: Pexprand(-116.0,-4),
		pan: Pstutter(Pexprand(1,19),Pwhite(0.0,1.0)),
	])
).play(quant: 1);
)
