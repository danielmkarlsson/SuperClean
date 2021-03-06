

/*

how to route Clean audio into post-processing in SuperCollider

This assumes that you have SuperClean running and accesible in ~clean

*/


// define a bus you'll be using for routing

~bus = Bus.audio(s, numChannels:2); // assuming stereo, expand if needed

~clean.orbits[0].outBus = ~bus; // play into that bus.


/*
Now, playing patterns in d1 in tidal should be silent.
*/

// listen directly
(
Ndef(\x, {
	var clean = InBus.ar(~bus, 2);
	clean
}).play;

)

// resonant low pass filter controlled by cursor
(
Ndef(\x, {
	var clean = InBus.ar(~bus, 2);
	RLPF.ar(clean, MouseY.kr(30, 20000, 1), MouseX.kr(0.01, 1, 1))
}).play;
)

// ... and so on.


// make a side chain controlled by second orbit, affecting the first

(
Ndef(\x, {
	var control = InBus.ar(~clean.orbits[1].dryBus, 2).sum;
	var clean = InBus.ar(~bus, 2);
	Compander.ar(clean, control, thresh:0.006, slopeBelow:1, slopeAbove: 0.1, clampTime:0.05, relaxTime:0.1)
	//clean * (1 - (Amplitude.kr(control) > 0.007).poll.lag(0.01));
}).play;
)



/*
cleaning up when you're done:
*/

~clean.orbits[0].outBus = 0;
~bus.free;




// algorave mastering, roughly according to
// https://mccormick.cx/news/entries/heuristic-for-algorave-mastering
(
~busses = ~clean.orbits.collect { |each|
	var bus = Bus.audio(~clean.server, ~clean.numChannels);
	each.outBus = bus;
	bus
}
);

(
Ndef(\x, {
	var level = 2;
	var distortion = 10;
	var reverbFeedback = 0.1;
	var all = ~busses.collect { |each| InBus.ar(each, each.numChannels) };
	var mix = all.sum { |x|
		var d = { 0.01.rand } ! x.size;
		DelayN.ar(x, d, d)
	};
	var lop = LocalIn.ar(~clean.numChannels);
	5.do { lop = AllpassL.ar(lop, 0.15, { ExpRand(0.03, 0.15) } ! 2, 3) };
	mix = lop * reverbFeedback + mix;
	mix = LeakDC.ar(mix);
	LocalOut.ar(mix);
	mix = Compander.ar(mix, mix, 0.3, slopeBelow:1, slopeAbove:0.5, clampTime:0.01, relaxTime:0.01);
	mix = (mix * distortion).tanh * (level / distortion.max(1));
	mix
}).play;
);



/*
cleaning up when you're done:
*/
(
Ndef(\x).clear;
~busses.do { |x| x.free };
~clean.orbits.do { |x| x.outBus = 0 };
);



