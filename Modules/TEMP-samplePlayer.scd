/*

EVENT - BASED
CORE SYNTHDEF EFFECTS FOR SUPERCLEAN
These synthdefs can be hacked at runtime, and hey something breaks, you can always download a fresh one.
Live coding them requires that you have your SuperClean instance in an environment variable called ~clean.

A quick note for hackers: You might think that default values for parameters get set in
the SynthDefs, but alas they do not. Default values for parameters get set in CleanAux.sc

*/

(
var numChannels = ~clean.numChannels;

(1..SuperClean.maxSampleNumChannels).do { |sampleNumChannels|

	var name = format("clean_sample_%_%", sampleNumChannels, ~clean.numChannels).asSymbol;


	SynthDef(name, {
		var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
		bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
		attack = \attack.ir(0.001).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir,
		gate = \gate.tr(1), timeScale = \timeScale.kr(1).abs, bufnum = \bufnum.ir, begin = \begin.kr, end = \end.kr(1),
		speed = \speed.kr(1), endSpeed = \endSpeed.kr(1);

		var sound, rate, phase, sawrate, numFrames, ampEnv, bendEnv;

		var holdTime = (BufFrames.ir(bufnum) * sampleNumChannels - 1) * timeScale;

		// change holdTime, or convert to Env.Perc for no sample overlapping.
		ampEnv = Env.linen(attack, holdTime, release, 1, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/);

		bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);

		// Playback speed.
		rate = Line.kr(speed, endSpeed, timeScale) * (freq / 60.midicps);

		// Sample phase.
		// BufSampleRate adjusts the rate if the sound file doesn't have the same rate as the soundcard.
		phase =  Sweep.ar(1, rate * BufSampleRate.ir(bufnum)) + (BufFrames.ir(bufnum) * begin);

		numFrames = BufFrames.ir(bufnum);
		sawrate = rate * BufSampleRate.ir(bufnum) / (absdif(begin, end) * numFrames);
		/*
		sound = BufRd.ar(
		numChannels: sampleNumChannels,
		bufnum: bufnum,
		phase: phase,
		loop: 0,
		interpolation: 4
		);
		*/

		sound = PlayBuf.ar(sampleNumChannels, bufnum, BufRateScale.ir(bufnum) * rate, startPos: phase, loop: 0.0, doneAction:0);
		sound = sound * amp;
		sound = sound * ampEnv;
		sound = CleanPan.ar(sound, numChannels, pan);

		Out.ar(out, sound)
	}).add;
};

~clean.addModule(\sound,
	{ |cleanEvent|
		if(~diversion.value.isNil) {
			if(~buffer.notNil) {
				// argumets could be omitted using getMsgFunc, but for making it easier to understand, we write them out
				cleanEvent.sendSynth(~instrument,  [
					bufnum: ~buffer,
					speed: ~spd,
					freq: ~freq,
					endSpeed: ~endspd,
					begin: ~bgn,
					end: ~end,
					loop: ~lop,
					pan: ~pan,
					out: ~out,
					amp: ~amp,
					bend: ~bnd ?? { SynthDescLib.global.at(~instrument).controlDict[\bend].defaultValue },
					bendTime: ~bnt ?? { SynthDescLib.global.at(~instrument).controlDict[\bendTime].defaultValue },
					bendStartOffset: ~bno ?? { SynthDescLib.global.at(~instrument).controlDict[\bendStartOffset].defaultValue },
					bendCurve: ~bnc ?? {SynthDescLib.global.at(~instrument).controlDict[\bendCurve].defaultValue },
					attack: ~atk ?? { SynthDescLib.global.at(~instrument).controlDict[\attack].defaultValue },
					release: ~rel ?? { SynthDescLib.global.at(~instrument).controlDict[\release].defaultValue },
					ampEnvCurve: ~crv ?? { SynthDescLib.global.at(~instrument).controlDict[\ampEnvCurve].defaultValue },
					gate: ~gate ?? { SynthDescLib.global.at(~instrument).controlDict[\gate].defaultValue },
					timeScale: ~tsc ?? { SynthDescLib.global.at(~instrument).controlDict[\timeScale].defaultValue },


				])
			} {
				if(~instrument.isNil) {
					"module 'sound': instrument not found: %".format(~sound).postln
				} {
					// here, we just derive the arguments as necessary from the environment
					cleanEvent.sendSynth(~instrument, ~argNames)
				}
			}
		}

});

)
