(
var numChannels = ~clean.numChannels;

(1..SuperClean.maxSampleNumChannels).do { |sampleNumChannels|

	var name = format("clean_sample_%_%", sampleNumChannels, ~clean.numChannels).asSymbol;


	SynthDef(name, {
		var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
		bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
		attack = \attack.ir(0.001).abs, release = \release.ir.abs, ampEnvCurve = \ampEnvCurve.ir,
		gate = \gate.tr(1), timeScale = \timeScale.kr.abs, bufnum = \bufnum.ir, begin = \begin.kr, end = \end.kr(1),
		speed = \speed.kr(1), endSpeed = \endSpeed.kr(1), loop = \loop.kr, trig = \trig.kr(1);

		var sound, rate, phase, sawrate, numFrames, ampEnv, bendEnv;

		var holdScale = (timeScale * (timeScale > 0)) + (1 * (timeScale <= 0) * (release <= 0));
		var holdTime = BufDur.ir(bufnum) * holdScale;

		ampEnv = Env.linen(attack, holdTime, release, 1, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/);

		bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);

		// Playback speed.
		rate = freq * 60.midicps.reciprocal * speed * bendEnv;

		sound = PlayBuf.ar(sampleNumChannels, bufnum, BufRateScale.ir(bufnum) * rate, trig, begin, loop);
		sound = sound * ampEnv * amp;
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
					speed: ~spd ?? { SynthDescLib.global.at(~instrument).controlDict[\speed].defaultValue },
					freq: ~freq,
					endSpeed: ~endspd,
					begin: ~bgn,
					end: ~end,
					loop: ~lop ?? { SynthDescLib.global.at(~instrument).controlDict[\loop].defaultValue },
					trig: ~trig ?? { SynthDescLib.global.at(~instrument).controlDict[\trig].defaultValue },
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
			} { // currently responsible for spawning non-sample sound sources!!!!!!!
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
