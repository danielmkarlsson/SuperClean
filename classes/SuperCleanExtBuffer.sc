+ Buffer {

	/*
	This guarantees that buffer info exists before the buffer is on the server.
	*/

	*cleanReadWithInfo { |server, path, startFrame = 0, numFrames = -1, allocate = true|
		var buffer = this.new(server), failed;
		if(server.serverRunning.not) { "server not running - cannot load sound file.".postln; this.throw };
		SoundFile.use(path, { |file|
			buffer.sampleRate = file.sampleRate;
			buffer.numFrames = file.numFrames;
			buffer.numChannels = file.numChannels;
			buffer.path = path;
		});
		failed = buffer.numFrames == 0;
		^if(failed) {
			"\n".post; "File reading failed for path: '%'\n\n".format(path).warn;
			buffer.free; // free buffer number
			nil
		} {
			if(allocate) { buffer.allocRead(path, startFrame, numFrames) };
			buffer
		}
	}
}