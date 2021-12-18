/*

Remote control Clean from Tidal via OSC

Open and close Clean Channels (CleanOrbit instances) on the fly.

This assumes you have stored clean in a variable ~clean

*/


// send OSC: "/new_clean", name, port, outBus
// outBus is an arbitrary channel offset (if it exceeds your hardware channels, it'll play on a private bus).
// The number of synth channels is fixed per SuperClean instance
// so you need several of them if you want different number of channels.

(
~allChannels = ~allChannels ? ();
OSCdef(\newclean, { |msg, time, tidalAddr|

	var name, port, outBus, old;
	#name, port, outBus = msg[1..];
	old = ~allChannels[name];
	if(old.notNil) { old.free };
	old[name] = CleanOrbit(~clean, port, outBus, tidalAddr);
}, '/new_clean', srcID: nil).fix; // srcID you may want to add NetAddr("127.0.0.1", <clean-port>)

// send OSC: "/remove_clean", name

OSCdef(\removeclean, { |msg, time, tidalAddr|

	var old, name = msg[1];
	old = ~allChannels[name];
	if(old.notNil) { old.free };
}, '/remove_clean', srcID: nil).fix; // srcID you may want to add NetAddr("127.0.0.1", <clean-port>)

)