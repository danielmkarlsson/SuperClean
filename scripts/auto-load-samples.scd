/*

If you have limited RAM, you may not want to preload all samples.
Then you can use this script to dynamically try and load them.

*/

(
// Keep track of what we have tried to load
var failed = Set.new;

// try to laod
var autoLoad = { |sound|
	if(failed.includes(sound).not) {
		failed.add(sound);
		~clean.loadOnly([sound]);
		if(~clean.buffers.at(sound).notNil) { failed.remove(sound) };
	} {
		// If loading fails, here is a message:
		"couldn't load soundfile for %\n".format(sound).postln
	}
};

// Use the "\notFound" hook in clean.
~clean.set(\notFound, { autoLoad.(~snd) });
)

// Try it out: while playing any pattern, now remove all samples:

~clean.freeSoundFiles;

// They should automatically come back when you reboot or recompile the class library.