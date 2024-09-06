


(
var functions = ();  // make a dictionary of functions
var recSynth, recBufs, counter = 0, recording = false;
var path = "~/chunks/";
var whichAux = ~clean.auxs[0];
var maxTime = 4; // allow a maximum of four seconds, adjust to your needs: this represents one cycle
var prevTime;

if(pathMatch(path +/+ "*").isEmpty) { unixCmd("mkdir" + path) };


~recBufs.do(_.free); // free them if they are left over (this is why we keep it in the environment variable)
// we need two buffers
~recBufs = recBufs = { Buffer.alloc(~clean.server, ~clean.server.sampleRate * maxTime, ~clean.numChannels) } ! 2;


SynthDef(\record, { |bufnum|
	var in = InFeedback.ar(whichOrbit.outBus, ~clean.numChannels);
	RecordBuf.ar(in, bufnum, lop:0, doneAction:2);
}).add;


functions[\startRec] = {

	if(recording) { functions[\stopRec].value };
	counter = counter + 1;
	prevTime = Main.elapsedTime + ~latency;
	~server.makeBundle(~latency, {
		recSynth = Synth(\record, [bufnum: (recBufs @@ counter)], ~server);
		recording = true;
	})
};

functions[\stopRec] = {
	if(recording) {
		~server.makeBundle(~latency, {
			var p = path +/+ "chunk" ++ Date.localtime.stamp ++ ".aiff";
			var buf = (recBufs @@ counter);
			buf.write(p.standardizePath, numFrames: Main.elapsedTime + ~latency - prevTime * buf.sampleRate);
			recSynth.free;
			recording = false;
		})
	}
};

// use the "diversion" key as a hook for playing the synth
~clean.orbits[0].defaultParentEvent[\diversion] = {
	var div = functions[~s];
	if(div.notNil) { div.value; 1.0 }
};



)


// open the directory with the sound files

systemCmd("open" + "~/chunks/");

