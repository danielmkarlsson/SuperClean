
// these are the global effects on each aux
~clean.auxs.do { |x| x.globalEffects.postln }

// say you want to add a global low pass filter on the first aux

// first you generate the synth defs for it
(
var numChannels = ~clean.numChannels;
(1..SuperClean.maxSampleNumChannels).do { |numChannels|
	SynthDef("clean_global_lpf" ++ numChannels, { |dryBus, effectBus, gate = 1, dry = 0|
		var ffreq, rq;
		var signal = In.ar(dryBus, numChannels);
		signal = signal.asArray.collect { |sig|
			ffreq = LFNoise2.kr(0.1).exprange(60, 13000);
			rq = 1/LFNoise2.kr(0.1).exprange(10, 20);
			RLPF.ar(sig, ffreq, rq).tanh;
		};
		signal = signal * EnvGen.kr(Env.asr, gate, doneAction:2);
		CleanPause.ar(signal.sum, graceTime:4);
		XOut.ar(effectBus, 1 - dry, signal)
	}).add;
};
)


// then add the effect to the aux
(
~clean.auxs.do { |x|
	x.globalEffects = ~clean.auxs[0].globalEffects.addFirst(
		GlobalCleanEffect(\clean_global_lpf, [\dry])
	)
};
~clean.auxs[0].initNodeTree;
)

~clean.auxs.do { |x| x.globalEffects.postln; " ----------".postln; }