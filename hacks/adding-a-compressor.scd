
// add a compressor module
(
~clean.orbits.do { |x|
	x.globalEffects = [
		GlobalCleanEffect(\clean_delay, [\delaytime, \delayfeedback, \delayAmp, \lock, \cps]),
		GlobalCleanEffect(\clean_reverb, [\size, \room, \dry]),
		GlobalCleanEffect(\clean_compressor),
		GlobalCleanEffect(\clean_monitor, [\cleanOut])
	]
};
)


// now play with different variants while you listen to tidal:


// a cleany hyperbolic tangens
(
SynthDef("clean_compressor" ++ ~clean.numChannels, { |dryBus, effectBus, gate = 1|
	var signal = In.ar(dryBus, ~clean.numChannels);

	signal = (signal * 5).tanh;
	signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
	Out.ar(effectBus, signal);
}, [\ir, \ir]).add;

s.freeAll; // restart all synths
)

// a cleany hyperbolic tangens, randomly drifting
(
SynthDef("clean_compressor" ++ ~clean.numChannels, { |dryBus, effectBus, gate = 1|
	var signal = In.ar(dryBus, ~clean.numChannels);

	signal = (signal * LFDNoise1.kr(0.1).exprange(4, 10)).tanh;
	signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
	Out.ar(effectBus, signal);
}, [\ir, \ir]).add;

s.freeAll; // restart all synths
)


// a compressor, adjust the parameters by ear
(
SynthDef("clean_compressor" ++ ~clean.numChannels, { |dryBus, effectBus, gate = 1|
	var signal = In.ar(dryBus, ~clean.numChannels);
	signal = Compander.ar(signal, signal * 4, 0.2,
		slopeBelow: 2,
        slopeAbove: 0.5,
        clampTime: 0.01,
        relaxTime: 0.01
	);
	signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
	Out.ar(effectBus, signal);
}, [\ir, \ir]).add;

s.freeAll; // restart all synths
)



