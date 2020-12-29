/*
This is an example startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")

This startup file you could use when you:
a) want to use a multichannel system (in this case 16 channels)
b) need to give access to remote instances of sclang for network music (maxLogins = 16)

This is useful also when your multichannel sound device isn't class compliant and you want to play on linux machines.
Then one host machine connected to the audio interface is enough, all others send messages to it.

*/

(
// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html

s.options.maxLogins = 2; // two logins

s.options.device = "Fireface 800 (6A)"; // replace this with your device

s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
s.options.memSize = 8192 * 16; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"

s.options.numOutputBusChannels = 16; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 2; // set this to your hardware input channel size, if necessary

s.reboot;
// boot the server and start SuperClean
s.waitForBoot {
	~clean = SuperClean(16, s); // sixteen output channels, increase if you want to pan across more channels
	~clean.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	// for example: ~clean.loadSoundFiles("/Users/myUserName/Clean/samples/*");
	// s.sync; // optionally: wait for samples to be read
	~clean.start(57120, [0, 0]);   // start listening on port 57120, create two auxs each sending audio to channel 0

	// optional, needed for the sclang tests only:
	(

		~d1 = ~clean.auxs[0]; // one aux
		~d2 = ~clean.auxs[1];

	);
};

s.latency = 0.3; // increase this if you get "late" messages
);
