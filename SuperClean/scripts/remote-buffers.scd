/*

If you are playing with your own SuperClean on a remote SuperClean server,
you may want to get sound file information from the remote SuperClean application,
which has loaded the buffers.

RemoteSoundfileInfo makes this easy.
It has to run on both sides of the network connection.

*/


~remote = CleanRemoteSoundfileInfo(~clean.soundLibrary).start(57120);

// ~addr = NetAddr("a.b.c.d", 57120); // on the requester side: replace "a.b.c.d" with the remote address

// testing with loopback
~addr = NetAddr("127.0.0.1", 57120);

// just posting them:
~remote.sendRequest(~addr, { |buffers| buffers.postln });

// adding them to the library of a second instance of a library:

~lib = CleanSoundLibrary(s, 2); // make a fresh one for testing
// ~lib = ~clean.soundLibrary; // this would be the one you'd use if you want to load into your current clean
~lib.freeAllSoundFiles;  // but better free the old ones. comment out if you know what you are doing ...

(
~remote.sendRequest(~addr, { |buffers|
	 // they come in key value pairs
	buffers.pairsDo { |key, buffer|
		[key, buffer].postln;
		~lib.addBuffer(key, buffer, appendToExisting: true)
	}
})
)

~lib.bufferEvents.keys
~lib.bufferEvents


