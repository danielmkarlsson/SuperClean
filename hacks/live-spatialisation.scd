
// live spatialisation over many channels / multichannel routing across non-adjacent channels


// getting tidal output into node proxies

Ndef(\cleany).ar(~clean.numChannels); // make a place for a signal
~clean.orbits.do { |each| each.outBus = Ndef(\cleany).bus };

// to see what you are doing, you can open a scope for the outputs:
s.scope(12);


/* route stereo input channels to output:

0 -> 0 (amp: 1)
1 -> 6 (amp: 0.5)
0 -> 8 (amp: 0.7)

*/

Ndef(\cleany).playN([0, 6, 8], [1, 0.5, 0.7], [0, 1, 0]); // outs, amps, ins

/* change them on the fly

0 -> 0 (amp: 1)
1 -> 6 (amp: 0.5)
0 -> 8 (amp: 0.7)

*/

Ndef(\cleany).playN([0, 7, 3], [0.6, 0.5, 0.7], [0, 1, 1]);


// you can specify a fadeTime to crossfade different settings
// e.g.

Ndef(\cleany).playN([1, 2, 4], [1, 0.5, 0.7], [0, 1, 0], fadeTime: 4);

// for more informations, see playN helpfile


// for using tidal for controlling the channel distribution
// best a multichannel SuperClean:

// simple 8-channel setup, synths only
(
~clean = SuperClean(8, s);
~clean.start(57120, 0 ! 4);
SuperClean.default = ~clean;
)

// same as above
(
Ndef(\cleany).ar(~clean.numChannels); // make a place for a signal
~clean.orbits.do { |each| each.outBus = Ndef(\cleany).bus };
Ndef(\cleany).scope;

Ndef(\cleany).play(0, 2); // this assumes that you have a stereo system. use playN as above for multichannel routing.
)

// now you can use # channel in tidal to send to different channels.
// simulate in sclang:

(
fork {
	16.do { |i|
		(type:\clean,  s:\imp, channel:i, sustain: 1.3, freq: 200 + (i * 20), pan:-1).play;
		0.2.wait
	}
}
)




