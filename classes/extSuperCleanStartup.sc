+ SuperClean {


	// convenient startup method
	// two output channels, increase if you want to pan across more channels
	// start listening on port 57120, create two auxs each sending audio to channel 0

	*start { |numChannels = 2, server, numAuxs = 12, port = 57120, senderAddr, path|
		~clean.free;
		server = server ? Server.default;
		server.options.numBuffers = 1024 * 256;
		server.options.memSize = 8192 * 16;
		server.options.maxNodes = 1024 * 32;
		// boot the server and start SuperClean
		server.waitForBoot {
			~clean = SuperClean(numChannels, server);
			~clean.loadSoundFiles(path);   // load samples (path can be passed in)
			server.sync;
			~clean.start(port, 0 ! numAuxs, senderAddr);
		};

		server.latency = 0.3;
	}

}

