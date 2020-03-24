
SuperClean.default = ~clean;

// test, can you hear
(
(type:\clean, orbit:0, s: \mmd).play;
(type:\clean, orbit:1, s: \mmd, speed:2/5).play;
)



(
Pdef(\x,
	Pbind(
		\type, \clean,
		\s, \mmd,
		\n, Pseq([1, 0, 0, 0, 0], inf),
		\speed, Pseq([1, 1, 0.5, 1.2], inf),
		\dur, 0.25 * Pseq([1, 1/2, 1, 2, 2, 1/2], inf),
		\room, Pseq([0, 0, 0.4], inf)
	)
).play
)


(
Pdef(\x,
	Ppar([
		Pbind(
			\type, \clean,
			\s, \mmd,
			\cut, Prand([0, 1, 2], inf),
			\n, Pseq([Prand([1, Pseq([1, 0, 5], 1), Pseq([0, 0])], 1), 0, 0, 0, 0, 0, 0, 0, 0], inf),
			\speed, Pseq([1, 1, 0.5, 1.2], inf),
			\dur, 0.25 * Pseq([1/2, 1/3, 2/3], inf),
			\room, Pseq([0, 0, 0.4], inf)
		),
		Pbind(
			\type, \clean,
			\s, \mmd,
			\dur, Pseq([0.5, 0.25, 0.25], inf),
			\amp, Prand([0.5, 0], inf)
		)
	])
).play
)


(
Pdef(\x,
	Pbind(
		\type, \clean,
		\s, \mmd,
		\n, Pseq([1, 0, 0, 0, 0], inf),
		\speed, Pseq([1, 1, 0.5, 1.2], inf),
		\dur, 0.25 * Pseq([1, 1/2, Prand([1, 1/2], 1), 2, 2, 1/2], inf),
		\cutoff, Pseg(Pwhite().linexp(0, 1, 300, 10000), 3, \lin, inf),
		\resonance, 0.3,
		\room, Pseq([0, 0, 0.4, 1], inf)
	)
).play
)




(
Pdef(\x,
	Pbind(
		\type, \clean,
		\s, \mmd,
		\n, Pseries(),
		\dur, 0.25 * Pseq([1, 1/2, 1], inf)
	)
).play
)


(
Pdef(\x,
	Pbind(
		\type, \clean,
		\s, \mmd,
		\n, Pseries(),
		\dur, 0.25 * Pseq([1, 1/2, 1], inf)
	)
).play
)


// multichannel expand effects
(
Pdef(\x,
	Pbind(
		\type, \clean,
		\s, \mmd,
		\dur, 0.25 * Pseq([1, 1/2, 1], inf),
		\cutoff, [1345, 1000, 400] + Prand([0, 0, 0, 0, 0, 0, -100, 200, [-100, 210]], inf),
		\resonance, 0.8
	)

).play
)
