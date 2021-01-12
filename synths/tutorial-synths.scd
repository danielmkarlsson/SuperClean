// a very basic starting point, just a 440Hz sine wave
(
SynthDef(\tutorial1, {|out|
	var sound = SinOsc.ar(440.0);
	OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, 0.5));
}).add
);

// now let's add some better duration control, and support for pan
(
SynthDef(\tutorial2, {|out, sustain=1, pan |
	var env = EnvGen.ar(Env.linen(0.01, 0.98, 0.01, 1,-3), timeScale:sustain, doneAction:2);
	var sound = SinOsc.ar(440.0);
	OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env));
}).add
);

// it's also nice to control the pitch
// the "num" parameter will be used as note number and converted to "freq" by SuperClean
// also, "bnd" will cause the pitch to drift
(
SynthDef(\tutorial3, {|out, sustain=1, pan, bnd, freq |
	var env = EnvGen.ar(Env.linen(0.01, 0.98, 0.01, 1, -3), timeScale:sustain, doneAction:2);
	var sound = SinOsc.ar(freq * Line.kr(1,1+bnd, sustain));
	OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env));
}).add
);

// we can also make the envelope a more interesting percussive shape
(
SynthDef(\tutorial4, {|out, sustain=1, pan, bnd, freq |
	var env = EnvGen.ar(Env.perc(0.001, 0.999, 1, -4), timeScale:sustain, doneAction:2);
	var sound = SinOsc.ar(freq * Line.kr(1,1+bnd, sustain));
	OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env));
}).add
);

// this one uses f from frequency, there is also the \freq key so why would you want that?
(
SynthDef(\tutorial5, {|out, sustain=1, pan, bnd, f |
	var env = EnvGen.ar(Env.perc(0.001, 0.999, 1, -4), timeScale:sustain, doneAction:2);
	var sound = SinOsc.ar(f * Line.kr(1,1+bnd, sustain));
	OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env));
}).add
);
