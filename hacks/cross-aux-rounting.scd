// reading input from another aux might work

(
var busses = ~clean.auxs.collect { |x| x.dryBus };

SynthDef(\readaux, { |out, amp = 1, n = 0| // number
	var bus, sound;

	bus = Select.kr(n, busses);
	sound = InFeedback.ar(bus, ~clean.numChannels);
	//sound = CombL.ar(sound, 0.2, 0.03, 1);

	Out.ar(out,
		sound * (amp * 2.5)
	)
}).add;
);