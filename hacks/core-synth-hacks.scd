/*

Hacking the core synths might be possible, you can live code them here.
This assumes you have stored clean in a variable ~clean

*/

/*

Change the way the samples are played back

e.g. Scratching through samples:

*/

(
// write variants for different sample buffer sizes
(1..SuperClean.maxSampleNumChannels).do { |sampleNumChannels|

	var name = format("clean_sample_%_%", sampleNumChannels, ~clean.numChannels);

	SynthDef(name, { |out, bufnum, sustain = 1, begin = 0, pan = 0, speed = 1, endSpeed = 1|

		var sound, rate, phase, scratch;

		// playback speed
		rate = Line.kr(speed, endSpeed, sustain);

		// sample phase
		// BufSampleRate adjusts the rate if the sound file doesn't have the same rate as the soundcard
		phase =  Sweep.ar(1, rate * BufSampleRate.ir(bufnum)) + (begin * BufFrames.ir(bufnum));

		scratch = LFNoise2.ar(12, 0.02 * BufSampleRate.ir(bufnum));
		phase = phase + scratch;
		phase = phase.clip(0, BufFrames.ir(bufnum));

		sound = BufRd.ar(
			numChannels: sampleNumChannels,
			bufnum: bufnum,
			phase: phase,
			loop: 0,
			interpolation: 4 // cubic interpolation
		);

		sound = CleanPan.ar(sound,  ~clean.numChannels, pan);

		OffsetOut.ar(out, sound)
	}, [\ir, \ir, \ir, \ir, \ir, \ir, \ir, \ir]).add;
};
)


// other things:

(
// write variants for different sample buffer sizes
(1..SuperClean.maxSampleNumChannels).do { |sampleNumChannels|

	var name = format("clean_sample_%_%", sampleNumChannels, ~clean.numChannels);

	SynthDef(name, { |out, bufnum, sustain = 1, begin = 0, pan = 0, speed = 1, endSpeed = 1|

		var sound, rate, phase, scratch;

		// playback speed
		rate = Line.kr(speed, endSpeed, sustain);

		// sample phase
		// BufSampleRate adjusts the rate if the sound file doesn't have the same rate as the soundcard
		phase =  Sweep.ar(1, rate * BufSampleRate.ir(bufnum)) + (begin * BufFrames.ir(bufnum));

		scratch = LFNoise2.ar(XLine.ar(12, 1000, sustain), 0.02 * BufSampleRate.ir(bufnum));
		phase = phase + scratch;
		phase = phase.clip(0, BufFrames.ir(bufnum));

		sound = BufRd.ar(
			numChannels: sampleNumChannels,
			bufnum: bufnum,
			phase: phase,
			loop: 0,
			interpolation: 4 // cubic interpolation
		);

		// ring mod
		sound = sound * SinOsc.ar(XLine.kr(40, 80, sustain));

		sound = CleanPan.ar(sound,  ~clean.numChannels, pan);

		OffsetOut.ar(out, sound)
	}, [\ir, \ir, \ir, \ir, \ir, \ir, \ir, \ir]).add;
};
)



