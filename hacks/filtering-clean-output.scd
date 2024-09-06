/*

how to route Clean audio into post-processing in SuperCollider maybe

This assumes that you have SuperClean running and accesible in ~clean

*/

// define a bus you'll be using for routing

~bus = Bus.audio(s, numChannels:2); // assuming stereo, expand if needed

~clean.auxs[0].outBus = ~bus; // play into that bus.

/*
Now, playing patterns.
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

// make a side chain controlled by second aux, affecting the first

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

~clean.auxs[0].outBus = 0;
~bus.free;