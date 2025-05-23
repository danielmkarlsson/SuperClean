/*

How to add new effects to SuperClean.

This is a three step process.

1. add the desired parameters to SuperCLean, so it can be used
2. add a module definition to Superclean, so it can be found when the parameter is not nil
3. add the synth def to SuperClean, so it can be played


The following example adds a weird spectral delay
This assumes you have an instance of SuperClean accessible via ~clean

*/

// in SuperCollider

// (2) add a module for superclean
// this adds a responder for the parameter
// for more examples see synths/core-modules

(
~clean.addModule('spectral-delay', { |cleanEvent|
	cleanEvent.sendSynth('spectral-delay' ++ ~clean.numChannels,
		// OPTIONAL
		// passing this array of parameters could be left out,
		// but it makes it clear what happens
		[
			xsdelay: ~xsdelay,
			tsdelay: ~tsdelay,
			sustain: ~sustain,
			out: ~out
		]
	)
}, { ~tsdelay.notNil or: { ~xsdelay.notNil } }); // play synth only if at least one of the two was given
)

// here you can see the effect order:
~clean.modules;

// OPTIONAL: you can reorder the effects, if you want e.g. the lpf to come after the delay:
~clean.orderModules(['spectral-delay', 'hpf', 'klm']);


// (3) make a synthdef (for more examples see core-synths)
(

var numChannels =  ~clean.numChannels;

SynthDef("spectral-delay" ++ numChannels, { |out, tsdelay, xsdelay = 1, sustain|

	var signal, delayTime, delays, freqs, filtered;
	var size = 16;
	var maxDelayTime = 0.2;

	signal = In.ar(out, numChannels);
	delayTime = tsdelay * maxDelayTime;
	filtered = (1..size).sum { |i|
		var filterFreq = i.linexp(1, size, 40, 17000);
		var sig = BPF.ar(signal, filterFreq, 0.005);
		// the delay pattern is determined from xsdelay by bitwise-and:
		DelayN.ar(sig, maxDelayTime, i & xsdelay * (1/size) * delayTime )
	};
	signal = signal * 0.2 + (filtered * 4); // this controls wet/dry
	ReplaceOut.ar(out, signal)

}).add;
)

