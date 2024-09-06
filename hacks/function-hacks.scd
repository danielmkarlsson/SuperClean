/*

You can define arbitrary functions maybe
This assumes you have stored clean in a variable ~clean

*/

// you may want to first try
// to use the addSynth(name, event) schema:

~clean.soundLibrary.addSynth(\test, (play: { "////////////// do whatever \\\\\\\\\\\\\\\\".postln }));

// test it here:
(type:\clean, clean: ~clean, snd: \test).play;


/*

But you can also divert more fundamentally.

*/


// simple example.
// execute arbitrary code
~clean.auxs[0].defaultParentEvent[\diversion] = { "\n*** now just this happens. *** \n".postln; };

// test it here
(type:\clean, clean: ~clean).play;

// you can pull out parameters:
~clean.auxs[0].defaultParentEvent[\diversion] = { "\n***".postln; ~s.postln };

(type:\clean, snd:\mmd, clean: ~clean).play;


// but it is not very useful like this
// you may prefer to divert only for specific sound values

(
var diversions = ();  // make a dictionary of functions
~diversions = diversions; // make it available out of scope
// use the "diversion" key as a hook for playing the synth
// return nil (unless you want the default action to also happen)
~d1.defaultParentEvent[\diversion] = { diversions[~snd].value };
)

// now you can populate the dictionary with specific diversions.
// say you want to divert the sound drm:

(
~diversions[\drm] = {
	"hello drm".postln;
};
~diversions[\hat] = {
	"hello hat".postln;
}
);

(type:\clean, snd:\drm, clean: ~clean).play;
(type:\clean, snd:\hat, clean: ~clean).play;

// execute arbitrary sc code
// you could maybe livecode this
(
~diversions[\drm]  = {
	Pfindur(~sustain ? 1,
		Pbind(
			\dur, 0.04,
			\midinote, Pbrown(-15, 15 ! 5, 0.3, inf) + 16,
			\out, ~out, \pan, ~pan, \amp, ~amp * 0.1
		)
	).play
};
)

(type:\clean, snd:\drm, clean: ~clean, out: 0, sustain: 2).play;

// clean up after yourself
~diversions[\drm]  = nil;
~diversions[\hat]  = nil;




