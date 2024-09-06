/*
// make sure you have sc3 plugins installed first
(
//var inOut = Server.default.options;inOut.outDevice = "BlackHole 2ch";inOut.inDevice = "BlackHole 2ch";//force devices
s.options.numBuffers = 1024 * 64; // increase if you need to load more samples
s.options.numWireBufs = 128; // increase if you get "exception in GraphDef_Recv: exceeded number of interconnect buffers."
s.options.memSize = 4096 * 256; // increase if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase if dropouts and the message "too many nodes"
s.options.sampleRate= 44100;
s.options.blockSize = 16;
s.options.numOutputBusChannels = 2; // OUTPUT CHANNELS GO HERE
s.recSampleFormat = "int24";
s.recHeaderFormat="wav";
s.options.numInputBusChannels = 2; // set to hardware input channel size, if necessary
s.latency = 0.3;
// MIDIClient.init; // Untoggle this when you want to do MIDI
// m = MIDIOut.new(0); // Maybe yours is different?
// m.latency = 0.3; // This should match s.latency
// thisProcess.platform.recordingsDir = "/your/path/here/"; // choose where supercollider recordings end up

// scnvim
if (\SCNvim.asClass.notNil) {
	Server.default.doWhenBooted {
		\SCNvim.asClass.updateStatusLine(1, 9670);
	}
};

QtGUI.palette = QPalette.dark; // switch to night mode for floating windows like the meter for example.

// A simple triangle wave synth in stereo with panning and a simple low pass filter
// This synthDef was written by Mads Kjeldgaard and requires the sc3 plugins
s.doWhenBooted{
	SynthDef.new(\default, {
		arg dur, attack=0.01, release=1.0,
		t_gate=1, out, freq=442, cutoff=5500,
		rq=1, pan=0.0, amp=0.5;

		var env = EnvGen.kr(Env.perc(attack, release), t_gate, timeScale: dur, doneAction: 2);
		var sig = DPW3Tri.ar(freq: freq, mul: env);
		sig = RLPF.ar(sig, cutoff.clip(20.0, 20000.0), rq.clip(0.0,1.0));
		sig = Pan2.ar(sig, pan);
		Out.ar(out, sig * amp);
	}).add;
};

s.waitForBoot {
	~clean = SuperClean(2, s); // two output channels, increase if you want to pan across more channels
	~clean.loadSoundFiles; // hot swap in samples from anywhere!
	// for example: ~clean.loadSoundFiles("~/Downloads/rnb");
	s.sync; // optionally: wait for samples to be read
	~clean.start([0,0,0]); // first 8 out looks like [0,2,4,6]
	SuperClean.default = ~clean; // make the clean key sequenceable inside of SuperCollider
	"[ SuperClean up + running ]".postln;
};
)
*/

(
// Configurar la ruta del archivo Setup.scd
var setupFilePath = "~/Setup.scd";

// Verificar si el archivo existe y luego ejecutarlo
if (File.exists(setupFilePath)) {
    setupFilePath.loadPath;
} {
    "El archivo Setup.scd no se encontró en la ruta especificada.".postln;
};
)