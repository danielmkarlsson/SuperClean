/*

adding new pitch models to a clean aux

*/



// to test it you could use this synth, and run it in SuperCollider

(
SynthDef(\testnote, { |out, sustain = 0.2, freq = 0, amp = 1, pan = 0, width = 0.3|
	var env, sound;
	sound = SinOsc.ar(freq, 0.5pi);
	env = EnvGen.ar(Env.perc(Rand(0.01, 0.02), sustain * Rand(1, 1.5)));
	OffsetOut.ar(out,
		CleanPan.ar(env * sound, ~clean.numChannels, pan, amp)
	)
}).add;
);


// the default function is kept here
// it takes ~n as one of its variables
~clean.auxs[0].defaultParentEvent[\freq].cs


// we modify it step by step

// post what we have

~clean.auxs[0].set(\freq, #{ (~n.postln + 60).midicps.postln });

// play half note higher

~clean.auxs[0].set(\freq, #{ (~n + 61).midicps });

// detune by a random frequency between -10 and 10 Hz

~clean.auxs[0].set(\freq, #{ (~n + 60).midicps + 10.0.rand2 });


// use an extended ocatve and an 11 TET scale

~clean.auxs[0].set(\freq, #{ 440 * (2.1 ** (~n / 11)) });

// interpret ~n as an overtone

~clean.auxs[0].set(\freq, #{ 220 * (~n + 1) });


// use the supercollider event pitch model, as explained in Event.help (last diagram on the page)
// we interpret ~n as scale degree
// defining other parameters in tidal you can send them from there on a note by note basis.

(
~clean.auxs[0].set(\freq, #{
	var degree = ~n;
	Event.default.use {
		~degree = degree;
		~freq.value
	}
}
)
);

// modal transposition
(
~clean.auxs[0].set(\freq, #{
	var degree = ~n;
	Event.default.use {
		~degree = degree;
		~mtranspose = 2;
		~freq.value
	}
}
)
);



// you can set parameters like scale, steps per octave etc.
(
~clean.auxs[0].set(\freq, #{
	var degree = ~n;
	Event.default.use {
		~degree = degree;
		~scale = [0, 4, 5, 7, 8];
		~stepsPerOctave = 10;
		~freq.value
	}
}
)
);


// back to default.
~clean.auxs[0].set(\freq, #{ (~n + 60).midicps });




