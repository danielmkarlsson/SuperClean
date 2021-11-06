/*

EVENT - BASED
CORE SYNTHDEF EFFECTS FOR SUPERCLEAN
These synthdefs can be hacked at runtime, and hey something breaks, you can always download a fresh one.
Live coding them requires that you have your SuperClean instance in an environment variable called ~clean.

A quick note for hackers: You might think that default values for parameters get set in
the SynthDefs, but alas they do not. Default values for parameters get set in CleanAux.sc

*/

/*
NOTES
NOTES
NOTES
NOTES


How to set location of clean_out dynamically? this will likely be explored in SuperClean.sc class defs- an easy way to redefine module order

Class Change: move ~clean.addModule (SuperClean.sc) to CleanSoundLibrary.sc and standardize? Or really it's the .sendSynth method in CleanEvent.sc that's dealing with arg name translation... maybe?


Make presetStore work

Amplitude: instead of output amount: input amplitude? \XXi ?

add or store SynthDefs?

\clean_downSampler: lincurve for rateScale parameter? find upper bound, and a nice curve that maybe excentuates better?

\clean_morphingFilter: should lpResonance and hpResonance be combined into same arg key? or have separate? (thinking maybe combine??)


Add compressor effect

*/



(
// Sample player.
/*/*/*/* Temporarily here to perserve order of execution: samples/sources before effects */*/*/*/
// Call it by providing \folderNameOfLoadedSamples as a value to the \snd key in a pattern, and specify which sample by providing a number to the \num key.
// Parameters:
// num | bgn | spd | lop | rtg |
// amp | pan | atk | rel | crv | gate | tsc | bnd | bnt | bno | bnc | freq | out
// // (NEW: lop, rtg, fdt, amp, atk, rel, crv, gate, tsc, bnd, bnt, bno, bnc)
(
(1..SuperClean.maxSampleNumChannels).do { |sampleNumChannels|

	var name = format("clean_sample_%_%", sampleNumChannels, ~clean.numChannels).asSymbol;


	SynthDef(name, {
		var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
		bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
		attack = \attack.ir(0.001).abs, release = \release.ir.abs, ampEnvCurve = \ampEnvCurve.ir, gate = \gate.tr(1),
		timeScale = \timeScale.kr.abs;
		var buf = \buf.ir, startPos = \startPos.kr, speed = \speed.kr(1), loop = \loop.kr, trig = \trig.kr(1);

		var bendEnv, rate, holdScale, holdTime, ampEnv, signal;

		bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
		rate = freq * 60.midicps.reciprocal * speed * bendEnv;

		// if timeScale and release are not explicitly defined, holdTime is the length of the sample, and release is bypassed
		// if release is set, and timeScale, is not, the hold portion of the Env is bypassed
		holdScale = (timeScale * (timeScale > 0)) + (1 * (timeScale <= 0) * (release <= 0));
		holdTime = BufDur.ir(buf) * holdScale;
		ampEnv = Env.linen(attack, holdTime, release, amp, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/);

		startPos = startPos.linlin(0, 1, 0, BufFrames.ir(buf)); // for scaling startPos btwn 0 & 1
		startPos = (startPos * (speed >= 0)) + ((BufFrames.ir(buf) - startPos) * (speed < 0));
		signal = PlayBuf.ar(sampleNumChannels, buf, BufRateScale.ir(buf) * rate, trig, startPos, loop);

		signal = signal * ampEnv;
		signal = CleanPan.ar(signal, ~clean.numChannels, pan);
		Out.ar(out, signal)
	}).add;
};

~clean.addModule(\sound,
	{ |cleanEvent|
		if(~diversion.value.isNil) {
			if(~buffer.notNil) {
				// argumets could be omitted using getMsgFunc, but for making it easier to understand, we write them out
				cleanEvent.sendSynth(~instrument,  [
					out: ~out,
					amp: ~amp,
					pan: ~pan,
					freq: ~freq,
					bend: ~bnd ?? { SynthDescLib.global.at(~instrument).controlDict[\bend].defaultValue },
					bendTime: ~bnt ?? { SynthDescLib.global.at(~instrument).controlDict[\bendTime].defaultValue },
					bendStartOffset: ~bno ?? { SynthDescLib.global.at(~instrument).controlDict[\bendStartOffset].defaultValue },
					bendCurve: ~bnc ?? {SynthDescLib.global.at(~instrument).controlDict[\bendCurve].defaultValue },
					attack: ~atk ?? { SynthDescLib.global.at(~instrument).controlDict[\attack].defaultValue },
					release: ~rel ?? { SynthDescLib.global.at(~instrument).controlDict[\release].defaultValue },
					ampEnvCurve: ~crv ?? { SynthDescLib.global.at(~instrument).controlDict[\ampEnvCurve].defaultValue },
					gate: ~gate ?? { SynthDescLib.global.at(~instrument).controlDict[\gate].defaultValue },
					timeScale: ~tsc ?? { SynthDescLib.global.at(~instrument).controlDict[\timeScale].defaultValue },
					buf: ~buffer ?? { SynthDescLib.global.at(~instrument).controlDict[\buf].defaultValue },
					speed: ~spd ?? { SynthDescLib.global.at(~instrument).controlDict[\speed].defaultValue },
					startPos: ~bgn ?? { SynthDescLib.global.at(~instrument).controlDict[\startPos].defaultValue },
					trig: ~rtg ?? { SynthDescLib.global.at(~instrument).controlDict[\trig].defaultValue },
					loop: ~lop ?? { SynthDescLib.global.at(~instrument).controlDict[\loop].defaultValue }
				])
			} { // currently responsible for spawning non-sample sound sources!!!!!!!
				/*if(~instrument.isNil) {
					"module 'sound': instrument not found: %".format(~sound).postln
				} {*/
					// here, we just derive the arguments as necessary from the environment
					cleanEvent.sendSynth(~instrument, ~argNames)
			// }
			}
		}
});
);

/*/*/*/* Instance Effects */*/*/*/
/*/*/*/* These effects are available for each event instance, and are freed at the end of each event. */*/*/*/





// Fuzz. Originally designed by Jonathan Liljedahl. http://kymatica.com/
// Activate it by providing the \fuz or \fzv key a value in a pattern.
// Parameters:
// fuz | fzv | fzi | fzo
// // (NEW: fzi, fzo, fuz changed to dry/wet control instead of bypass)
(
SynthDef (\clean_fuzz, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	gain = \gain.kr(3);
	var signal = Array.newClear(3), gate; // array index: [0] - in/clean, [1] - distortion/parallel, [2] - main
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	gate = Amplitude.ar(signal[0], 0.005, 0.005) > 0.002;
	signal[1] = (signal[0] * 4).tanh;
	signal[1 .. 2] = MidEQ.ar(signal[1], 100, 1, 20);
	signal[2] = (Limiter.ar(signal[2] * 50) * gain).wrap(-1, 1) + signal[2];
	signal[2] = signal[2].tanh;
	signal[2] = MidEQ.ar(signal[2], 200, 1, 20);
	signal[2] = MidEQ.ar(signal[2], 1000,1, -20);
	signal[2] = LPF.ar(signal[2], 8000);
	signal[2] = (signal[2] + signal[1]).tanh;
	signal[2] = MidEQ.ar(signal[2], 4000, 1, -20);
	signal[2] = XFade2.ar(signal[0], signal[2] * gate, blend);
	signal[2] = signal[2] * outputGain;
	ReplaceOut.ar(bus, signal[2])
}).add; // or store?

~clean.addModule(\fuz, { |cleanEvent|
	cleanEvent.sendSynth(\clean_fuzz, [
		gain: ~fzv ?? { SynthDescLib.global.at(\clean_fuzz).controlDict[\gain].defaultValue },
		inputGain: ~fzi ?? { SynthDescLib.global.at(\clean_fuzz).controlDict[\inputGain].defaultValue },
		outputGain: ~fzo ?? { SynthDescLib.global.at(\clean_fuzz).controlDict[\outputGain].defaultValue },
		blend: ~fuz ?? { SynthDescLib.global.at(\clean_fuzz).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~fuz.notNil or: ~fzv.notNil });

// presetStore.(\fuz);
);




// Bit-reduction effect.
// Activate it by providing the \bit key a value in a pattern.
// Parameters:
// bit | bii | bio | bib
// // (NEW: bii, bio, bib, (bit range reduced to 0-1))
(
SynthDef(\clean_bitReducer, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	crush = \crush.kr(0.8);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	crush = crush.lincurve(0, 1, 1.65, 6.5, 3);
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].round(0.5 ** (crush - 1));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\bit, { |cleanEvent|
	cleanEvent.sendSynth(\clean_bitReducer, [
		crush: ~bit ?? { SynthDescLib.global.at(\clean_bitReducer).controlDict[\crush].defaultValue },
		inputGain: ~bii ?? { SynthDescLib.global.at(\clean_bitReducer).controlDict[\inputGain].defaultValue },
		outputGain: ~bio ?? { SynthDescLib.global.at(\clean_bitReducer).controlDict[\outputGain].defaultValue },
		blend: ~bib ?? { SynthDescLib.global.at(\clean_bitReducer).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~bit.notNil });

// presetStore.(\bit);
);




// Sample-reduction effect.
// Activate it by providing the \sam key a value in a pattern.
// Parameters:
// sam | sai | sao | sab
// // (NEW: sai, sao | sab)
(
SynthDef(\clean_downSampler, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	rateScale = \rateScale.kr(4).max(1.0022);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = Latch.ar(signal[0], Impulse.ar(SampleRate.ir * rateScale.reciprocal));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\sam, { |cleanEvent|
	cleanEvent.sendSynth(\clean_downSampler, [
		rateScale: ~sam ?? { SynthDescLib.global.at(\clean_downSampler).controlDict[\rateScale].defaultValue },
		inputGain: ~sai ?? { SynthDescLib.global.at(\clean_downSampler).controlDict[\inputGain].defaultValue },
		blend: ~sab ?? { SynthDescLib.global.at(\clean_downSampler).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~sam.notNil });

// presetStore.(\sam);
);




// High-pass filter.
// Activate it by providing the \hpf or \hpq key a value in a pattern.
// Parameters:
// hpf | hpq | hpi | hpo | hpb
// // (NEW: hpi, hpo, hpb)
(
SynthDef(\clean_highPassFilter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	cutoff = \cutoff.kr(440).clip(20, 20000), resonance = \resonance.kr.linexp(0, 1, 1, 0.001);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = RHPF.ar(signal[0], cutoff, resonance);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\hpf, { |cleanEvent|
	cleanEvent.sendSynth(\clean_highPassFilter, [
		cutoff: ~hpf ?? { SynthDescLib.global.at(\clean_highPassFilter).controlDict[\cutoff].defaultValue },
		resonance: ~hpq ?? { SynthDescLib.global.at(\clean_highPassFilter).controlDict[\resonance].defaultValue },
		inputGain: ~hpi ?? { SynthDescLib.global.at(\clean_highPassFilter).controlDict[\inputGain].defaultValue },
		outputGain: ~hpo ?? { SynthDescLib.global.at(\clean_highPassFilter).controlDict[\outputGain].defaultValue },
		blend: ~hpb ?? { SynthDescLib.global.at(\clean_highPassFilter).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~hpf.notNil or: ~hpq.notNil });

// presetStore.(\hpf);
);




// Band-pass filter.
// Activate it by providing the \bpf or \bpq key a value in a pattern.
// Parameters:
// bpf | bpq | bpi | bpo | bpb
// // (NEW: bpi, bpb)
(
SynthDef(\clean_bandPassFilter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	cutoff = \cutoff.kr(440).clip(20, 20000), resonance = \resonance.kr.linlin(0, 1, 1, 10000);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = BPF.ar(signal[0], cutoff, resonance.reciprocal) * resonance.max(1);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\bpf, { |cleanEvent|
	cleanEvent.sendSynth(\clean_bandPassFilter, [
		cutoff: ~bpf ?? { SynthDescLib.global.at(\clean_bandPassFilter).controlDict[\cutoff].defaultValue },
		resonance: ~bpq ?? { SynthDescLib.global.at(\clean_bandPassFilter).controlDict[\resonance].defaultValue },
		inputGain: ~bpi ?? { SynthDescLib.global.at(\clean_bandPassFilter).controlDict[\inputGain].defaultValue },
		outputGain: ~bpo ?? { SynthDescLib.global.at(\clean_bandPassFilter).controlDict[\outputGain].defaultValue },
		blend: ~bpb ?? { SynthDescLib.global.at(\clean_bandPassFilter).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~bpf.notNil or: ~bpq.notNil });

// presetStore.(\bpf);
);




// Low-pass filter.
// Activate it by providing the \lpf or \lpq key a value in a pattern.
// Parameters:
// lpf | lpq | lpi | lpo | lpb
// // (NEW: lpi, lpb)
(
SynthDef(\clean_lowPassFilter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	cutoff = \cutoff.kr(440).clip(20, 20000), resonance = \resonance.kr.linexp(0, 1, 1, 0.001);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = RLPF.ar(signal[0], cutoff, resonance);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\lpf, { |cleanEvent|
	cleanEvent.sendSynth(\clean_lowPassFilter, [
		cutoff: ~lpf ?? { SynthDescLib.global.at(\clean_lowPassFilter).controlDict[\cutoff].defaultValue },
		resonance: ~lpq ?? { SynthDescLib.global.at(\clean_lowPassFilter).controlDict[\resonance].defaultValue },
		inputGain: ~lpi ?? { SynthDescLib.global.at(\clean_lowPassFilter).controlDict[\inputGain].defaultValue },
		outputGain: ~lpo ?? { SynthDescLib.global.at(\clean_lowPassFilter).controlDict[\outputGain].defaultValue },
		blend: ~lpb ?? { SynthDescLib.global.at(\clean_lowPassFilter).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~lpf.notNil or: ~lpq.notNil });

// presetStore.(\lpf);
);




// Waveshaper.
// Activate it by providing the one of the keys a value in a pattern.
// Parameters:
// shp | sac | slo | shi | sho | lot | hit | spi | spo | shb
// // (NEW: spi, spo, shb)
(
SynthDef(\clean_waveshaper, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	lowAmount = \lowAmount.kr(1), highAmount = \highAmount.kr, ampCompensation = \ampCompensation.kr(0.99).clip(0.0001, 1.0),
	lowThreshold = \lowThreshold.kr.linlin(0.0,1.0,-1.0,1.0), highThreshold = \highThreshold.kr(1).linlin(0.0,1.0,-1.0,1.0),
	depth = \depth.kr(0.5).clip(0, 1 - 4e-10).explin(0.001, 1, 0.0, 0.999999), offset = \offset.kr.linlin(0.0,1.0,1.0,5.0);
	var abs, diff, gainStage = 1, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	gainStage = 1.0 - ((ampCompensation * depth) * (depth + ampCompensation).reciprocal);
	depth = (1.0 * depth) * (1.0 - depth).reciprocal;
	highAmount = highAmount * offset;
	lowAmount = lowAmount * offset;
	abs = highAmount - lowAmount;
	lowAmount = lowAmount + (abs * lowThreshold);
	highAmount = highAmount - (abs * highThreshold);
	diff = 1 - ((lowAmount - highAmount) + (highAmount * lowAmount));
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = ((1 + depth) * signal[0]) * (1 + (depth * abs(signal[0]))).reciprocal;
	signal[1] = Fold.ar(signal[1], lowAmount, highAmount);
	signal[1] = Limiter.ar(LeakDC.ar(signal[1] * (gainStage + diff)));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\shp,{ |cleanEvent|
	cleanEvent.sendSynth(\clean_waveshaper, [
		depth: ~shp ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\depth].defaultValue },
		ampCompensation: ~sac ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\ampCompensation].defaultValue }, // shc
		lowAmount: ~slo ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\lowAmount].defaultValue }, // shl
		highAmount: ~shi ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\highAmount].defaultValue }, // shh
		offset: ~sho ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\offset].defaultValue }, // sho
		lowThreshold: ~lot ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\lowThreshold].defaultValue }, // slt
		highThreshold: ~hit ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\highThreshold].defaultValue }, // slh
		inputGain: ~spi ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\inputGain].defaultValue }, // shi
		outputGain: ~spo ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\outputGain].defaultValue }, // shi
		blend: ~spb ?? { SynthDescLib.global.at(\clean_waveshaper).controlDict[\blend].defaultValue }, // shb
		bus: ~out
	])
}, { ~shp.notNil or: ~sac.notNil or: ~slo.notNil or: ~shi.notNil or: ~sho.notNil or: ~lot.notNil or: ~hit.notNil });

// presetStore.(\shp);
);




// Frequency shifter.
// Activate it by providing the \fsh, \fsm, or \fsp key a value in a pattern.
// Parameters:
// fsh | fsm | fsp | fsi | fso | fsb
// // (NEW: fsp, fsi, fso, fsb)
(
SynthDef(\clean_frequencyShifter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	freq = \freq.kr, freqMultiplier = \freqMultiplier.kr, freqShift = \freqShift.kr, phaseShift = \phaseShift.kr.mod(2pi);
	var shift, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	shift = freq * freqMultiplier + freqShift;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = FreqShift.ar(signal[0], shift, phaseShift);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\fsh, { |cleanEvent|
	cleanEvent.sendSynth(\clean_frequencyShifter, [
		freqShift: ~fsh ?? { SynthDescLib.global.at(\clean_frequencyShifter).controlDict[\freqMultiplier].defaultValue },
		freqMultiplier: ~fsm ?? { SynthDescLib.global.at(\clean_frequencyShifter).controlDict[\freqMultiplier].defaultValue },
		phaseShift: ~fsp ?? { SynthDescLib.global.at(\clean_frequencyShifter).controlDict[\phaseShift].defaultValue },
		freq: ~freq, // no preset value: set by sound source freq calculation
		inputGain: ~fsi ?? { SynthDescLib.global.at(\clean_frequencyShifter).controlDict[\inputGain].defaultValue },
		outputGain: ~fso ?? { SynthDescLib.global.at(\clean_frequencyShifter).controlDict[\outputGain].defaultValue },
		blend: ~fsb ?? { SynthDescLib.global.at(\clean_frequencyShifter).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~fsh.notNil or: ~fsm.notNil or: ~fsp.notNil });

// presetStore.(\fsh);
);




// Triode-like distortion. Made by Ben Gold
// Activate it by providing the \tri key a value in a pattern.
// Parameters:
// tri | tgi | tgo | trb
// // (NEW: tgi, tgo, trb)
(
SynthDef(\clean_triodeDistortion, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	depth = \depth.kr;
	var distortion, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	distortion = depth * 10 + 0.001;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = (signal[0] * (signal[0] > 0)) + ((signal[0] * distortion).tanh * (distortion.reciprocal * (signal[0] < 0)));
	signal[1] = LeakDC.ar(signal[1]);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\tri, { |cleanEvent|
	cleanEvent.sendSynth(\clean_triodeDistortion, [
		depth: ~tri ?? { SynthDescLib.global.at(\clean_triodeDistortion).controlDict[\depth].defaultValue },
		inputGain: ~tgi ?? { SynthDescLib.global.at(\clean_triodeDistortion).controlDict[\inputGain].defaultValue },
		outputGain: ~tgo ?? { SynthDescLib.global.at(\clean_triodeDistortion).controlDict[\outputGain].defaultValue },
		blend: ~trb ?? { SynthDescLib.global.at(\clean_triodeDistortion).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~tri.notNil });

// presetStore.(\tri);
);




// Octaver. Originally from Sonic-Pi, made for SuperDirt by Ben Gold.
// Activate it by providing the \ocu, \ocd, or \ocq key a value in a pattern.
// Parameters:
// ocu | ocd | ocq | occ | oci | oco | ocb
// // (NEW: occ, oci, oco, ocb)
(
SynthDef(\clean_octaver, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	cutoff = \cutoff.kr(440), octaveAmp = [\ampOctaveUp.kr, \ampOctaveDown.kr, \ampTwoOctavesDown.kr];
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var octave = Array.newClear(4); // array index: [0] - octave up, [1] - neutral, [2] - octave down, [3] - two octaves down
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	octave[0] = LeakDC.ar(signal[0].abs) * 2; // oct above
	octave[1] = LPF.ar(signal[0], cutoff); // neutral
	octave[2] = ToggleFF.ar(octave[1]); // oct below
	octave[3] = ToggleFF.ar(octave[2]); // 2x below
	signal[1] = SelectX.ar(octaveAmp[0].clip(0.0, 1.0), [signal[0], octaveAmp[0] * octave[0]]);
	signal[1] = signal[1] + (octaveAmp[1] * octave[2] * octave[1]) + (octaveAmp[2] * octave[3] * octave[1]);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\oct, { |cleanEvent|
	cleanEvent.sendSynth(\clean_octaver, [
		ampOctaveUp: ~ocu ?? { SynthDescLib.global.at(\clean_octaver).controlDict[\ampOctaveUp].defaultValue },
		ampOctaveDown: ~ocd ?? { SynthDescLib.global.at(\clean_octaver).controlDict[\ampOctaveDown].defaultValue },
		ampTwoOctavesDown: ~ocq ?? { SynthDescLib.global.at(\clean_octaver).controlDict[\ampTwoOctavesDown].defaultValue },
		cutoff: ~occ ?? { SynthDescLib.global.at(\clean_octaver).controlDict[\cutoff].defaultValue },
		inputGain: ~oci ?? { SynthDescLib.global.at(\clean_octaver).controlDict[\inputGain].defaultValue },
		outputGain: ~oco ?? { SynthDescLib.global.at(\clean_octaver).controlDict[\outputGain].defaultValue },
		blend: ~ocb ?? { SynthDescLib.global.at(\clean_octaver).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~ocu.notNil or: ~ocd.notNil or: ~ocq.notNil });

// presetStore.(\oct);
);




// Ring Modulation.
// Activate it by providing the \rma, \rmf, \rdf, or \rdt key a value in a pattern.
// Parameters:
// rma | rmf | rdf | rdt | rmi | rmo | rmb
// // (NEW: rmi, rmo, rmb)
(
SynthDef(\clean_ringModulation, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	depth = \depth.kr(1), modFreq = \modFreq.kr(100), glissandoFreq = \glissandoFreq.kr, glissandoTime = \glissandoTime.kr;
	var modulator, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	glissandoFreq = ((glissandoFreq.abs > 0) * glissandoFreq) + ((glissandoFreq.abs < 1) * modFreq); // use modFreq if gliss not specified
	modulator = depth * SinOsc.ar(XLine.kr(glissandoFreq, modFreq, glissandoTime).clip(20, 20000));
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].ring1(modulator);
	signal[1] = XFade2.ar(signal[0], signal[1] * 0.8, blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\rma, { |cleanEvent|
	cleanEvent.sendSynth(\clean_ringModulation, [
		depth: ~rma ?? { SynthDescLib.global.at(\clean_ringModulation).controlDict[\depth].defaultValue },
		modFreq: ~rmf ?? { SynthDescLib.global.at(\clean_ringModulation).controlDict[\modFreq].defaultValue },
		glissandoFreq: ~rdf, // no preset value, uses modFreq if not specified (in SynthDef)
		glissandoTime: ~rdt ?? { SynthDescLib.global.at(\clean_ringModulation).controlDict[\glissandoTime].defaultValue },
		inputGain: ~rmi ?? { SynthDescLib.global.at(\clean_ringModulation).controlDict[\inputGain].defaultValue },
		outputGain: ~rmo ?? { SynthDescLib.global.at(\clean_ringModulation).controlDict[\outputGain].defaultValue },
		blend: ~rmb ?? { SynthDescLib.global.at(\clean_ringModulation).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~rma.notNil or: ~rmf.notNil or: ~rdf.notNil or: ~rdt.notNil });

// presetStore.(\rma);
);




// Crunchy distortion with a lot of high harmonics.
// Activate it by providing the \dst key a value in a pattern.
// Parameters:
// dst | dsf | dsr | dsm | dsi | dso | dsb
// // (NEW: dsf, dsr, dsm, dsi, dso, dsb)
(
SynthDef(\clean_distortion, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	depth = \depth.kr(1), mix = \mix.kr, filterScaling = \filterScaling.kr(0.25).linexp(0.0, 1.0, 0.75, 2.3),
	ampScaling = \ampScaling.kr.clip(0, 1), ringScaling = \ringScaling.kr(0.1).clip(0.01, 2);
	var filterFreq = 60, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	filterFreq = filterFreq * filterScaling;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = CrossoverDistortion.ar(signal[0], ((depth * 0.75) * 0.2).clip(0.2, 1.2), 0.01);
	signal[1] = signal[1] + (0.1 * depth * DynKlank.ar(`[
		[
			filterFreq,
			filterFreq + 1,
			filterFreq * 4,
			filterFreq * 50 + (SinOsc.ar(filterFreq + 2) * 100)
		], [
			1,
			1 + ((ampScaling > 0) * ampScaling).max(0.01).neg,
			1 + ((ampScaling > 0) * (ampScaling * 1.08)).min(0.99).neg,
			1 + ((ampScaling > 0) * (ampScaling * 1.18)).min(0.99).neg,
		], [
			ringScaling,
			ringScaling,
			ringScaling * 0.5,
			ringScaling * 0.1]], (signal[0] * (1 - mix)) + (signal[1] * mix)));
	signal[1] = (signal[1].cubed * 8).softclip * 0.5;
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1]) // changed from Out to ReplaceOut due to blend control
}).add;

~clean.addModule(\dst, { |cleanEvent|
	cleanEvent.sendSynth(\clean_distortion, [
		depth: ~dst ?? { SynthDescLib.global.at(\clean_distortion).controlDict[\depth].defaultValue },
		filterScaling: ~dsf ?? { SynthDescLib.global.at(\clean_distortion).controlDict[\filterScaling].defaultValue },
		ampScaling: ~dsa ?? { SynthDescLib.global.at(\clean_distortion).controlDict[\ampScaling].defaultValue },
		ringScaling: ~dsr ?? { SynthDescLib.global.at(\clean_distortion).controlDict[\ringScaling].defaultValue },
		mix: ~dsm ?? { SynthDescLib.global.at(\clean_distortion).controlDict[\mix].defaultValue },
		inputGain: ~dsi ?? { SynthDescLib.global.at(\clean_distortion).controlDict[\inputGain].defaultValue },
		outputGain: ~dso ?? { SynthDescLib.global.at(\clean_distortion).controlDict[\outputGain].defaultValue },
		blend: ~dsb ?? { SynthDescLib.global.at(\clean_distortion).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~dst.notNil });

// presetStore.(\dst);
);




// Spectral Delay. Made by Mads Kjeldgaard.
// Activate it by providing the \sdx or \sdt key a value in a pattern.
// Parameters:
// sdx | sdt | sdq | sda | sdi | sdo | sdb
// // (NEW: sdi, sdo, sdb)
(
SynthDef(\clean_spectralDelay, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	depth = \depth.kr(1), layerScale = \layerScale.kr(10), delayScale = \delayScale.kr(2), resonance = \resonance.kr(0.02).clip(0, 1);
	var size = 16, maxDelayTime = 0.2, delayTime, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	delayTime = delayScale * maxDelayTime;
	resonance = ((resonance < 0.1) * (resonance * 0.1).linlin(0.0, 1.0, 0.005, 1.0)) + ((resonance >= 0.1) * resonance); // scale resonance
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = (1 .. size).sum { |i|
		var filterFreq = i.linexp(1, size, 40, 17000);
		var sig = BPF.ar(signal[0], filterFreq, resonance);
		DelayN.ar(sig, maxDelayTime, i & layerScale * size.reciprocal * delayTime) // the delay pattern is determined by bitwise-and of layerScale
	};
	signal[1] = signal[0] * 0.2 + (signal[1] * 4 * depth);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\sdx, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralDelay, [
		layerScale: ~sdx ?? { SynthDescLib.global.at(\clean_spectralDelay).controlDict[\layerScale].defaultValue },
		delayScale: ~sdt ?? { SynthDescLib.global.at(\clean_spectralDelay).controlDict[\delayScale].defaultValue },
		depth: ~sda ?? { SynthDescLib.global.at(\clean_spectralDelay).controlDict[\depth].defaultValue },
		resonance: ~sdq ?? { SynthDescLib.global.at(\clean_spectralDelay).controlDict[\resonance].defaultValue },
		inputGain: ~sdi ?? { SynthDescLib.global.at(\clean_spectralDelay).controlDict[\inputGain].defaultValue },
		outputGain: ~sdo ?? { SynthDescLib.global.at(\clean_spectralDelay).controlDict[\outputGain].defaultValue },
		blend: ~sdb ?? { SynthDescLib.global.at(\clean_spectralDelay).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~sdx.notNil or: ~sdt.notNil });

// presetStore.(\sdx);
);




// Spectral Freeze. Made by Mads Kjeldgaard.
// Activate it by providing the \frz key a value in a pattern.
// Parameters:
// frz | fri | fro | frb
// // (NEW: fri, fro, frb)
(
// { // create 8 buffers with differing frame amounts to allow for different tonal qualities
// var buffer;
// Array.geom(8, 128, 2).do { |numFrames, i| buffer[i] = Buffer.alloc(s, numFrames); };

SynthDef(\clean_spectralFreeze, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(0.5).linlin(0.0, 1.0, -1.0, 1.0),
	freeze = \freeze.kr.round(1);
	// selectBuffer = \selectBuffer.kr(4).wrap(0, 7);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	// signal[1] = signal[0].asArray.collect { |x| FFT(buffer[selectBuffer], x) };
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_Freeze(signal[1], freeze));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;


~clean.addModule(\frz, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralFreeze, [
		freeze: ~frz ?? { SynthDescLib.global.at(\clean_spectralFreeze).controlDict[\freeze].defaultValue },
		// selectBuffer: ~frs ?? { SynthDescLib.global.at(\clean_spectralFreeze).controlDict[\selectBuffer].defaultValue },
		inputGain: ~fri ?? { SynthDescLib.global.at(\clean_spectralFreeze).controlDict[\inputGain].defaultValue },
		outputGain: ~fro ?? { SynthDescLib.global.at(\clean_spectralFreeze).controlDict[\outputGain].defaultValue },
		blend: ~frb ?? { SynthDescLib.global.at(\clean_spectralFreeze).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~frz.notNil } );

// presetStore.(\frz);
// }
);





// Spectral Comb Filter. Made by Mads Kjeldgaard.
// Activate it by providing the \cmb key a value in a pattern.
// Parameters:
// cmb | cmi | cmo | cmw
// // (NEW: cmi, cmo, cmw)
(
SynthDef(\clean_spectralCombFilter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	comb = \comb.kr.clip(0.0, 1.0);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048, teeth = 256;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_RectComb(signal[1], numTeeth: teeth * comb, width: 1 - comb));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\cmb, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralCombFilter, [
		comb: ~cmb ?? { SynthDescLib.global.at(\clean_spectralCombFilter).controlDict[\comb].defaultValue },
		inputGain: ~cmi ?? { SynthDescLib.global.at(\clean_spectralCombFilter).controlDict[\inputGain].defaultValue },
		outputGain: ~cmo ?? { SynthDescLib.global.at(\clean_spectralCombFilter).controlDict[\outputGain].defaultValue },
		blend: ~cmw ?? { SynthDescLib.global.at(\clean_spectralCombFilter).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~cmb.notNil });

// presetStore.(\cmb);
);




// Spectral Smearing Effect. Made by Mads Kjeldgaard.
// Activate it by providing the \smr key a value in a pattern.
// Parameters:
// smr | smi | smo | smb
// // (NEW: smi, smo, smb)
(
SynthDef(\clean_spectralSmear, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	smear = \smear.kr.linexp(0.0,1.0,1,64);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_MagSmear(signal[1], smear));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\smr, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralSmear, [
		smear: ~smr ?? { SynthDescLib.global.at(\clean_spectralSmear).controlDict[\smear].defaultValue },
		inputGain: ~smi ?? { SynthDescLib.global.at(\clean_spectralSmear).controlDict[\inputGain].defaultValue },
		outputGain: ~smo ?? { SynthDescLib.global.at(\clean_spectralSmear).controlDict[\outputGain].defaultValue },
		blend: ~smb ?? { SynthDescLib.global.at(\clean_spectralSmear).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~smr.notNil });

// presetStore.(\smr);
);




// Spectral Scrambling Effect. Made by Mads Kjeldgaard.
// Activate it by providing the \scm key a value in a pattern.
// Parameters:
// scm | scs | sci | sco, scb
// // (NEW: scs, sci, sco, scb)
(
SynthDef(\clean_spectralScrambler, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	scramble = \scramble.kr, reorder = \reorder.kr;
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_BinScramble(signal[1], scramble, scramble, reorder > 0.1));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\scm, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralScrambler, [
		scramble: ~scm ?? { SynthDescLib.global.at(\clean_spectralScrambler).controlDict[\scramble].defaultValue },
		reorder: ~scs ?? { SynthDescLib.global.at(\clean_spectralScrambler).controlDict[\reorder].defaultValue },
		inputGain: ~sci ?? { SynthDescLib.global.at(\clean_spectralScrambler).controlDict[\inputGain].defaultValue },
		outputGain: ~sco ?? { SynthDescLib.global.at(\clean_spectralScrambler).controlDict[\outputGain].defaultValue },
		blend: ~scb ?? { SynthDescLib.global.at(\clean_spectralScrambler).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~scm.notNil });

// presetStore.(\scm);
);




// Spectral Frequency Bin-Shifting Effect. Made by Mads Kjeldgaard.
// Activate it by providing the \sbs key a value in a pattern.
// Parameters:
// sbs | sbi | sbo | sbb
// // (NEW: sbi, sbo, sbb)
(
SynthDef(\clean_spectralBinShifter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	shift = \shift.kr(2).clip(0.2, 65);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_BinShift(signal[1], shift.linlin(0.0,1.0,0.01,4.0), shift * 10, 1));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\sbs, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralBinShifter, [
		shift: ~sbs ?? { SynthDescLib.global.at(\clean_spectralBinShifter).controlDict[\shift].defaultValue },
		inputGain: ~sbi ?? { SynthDescLib.global.at(\clean_spectralBinShifter).controlDict[\inputGain].defaultValue },
		outputGain: ~sbo ?? { SynthDescLib.global.at(\clean_spectralBinShifter).controlDict[\outputGain].defaultValue },
		blend: ~sbb ?? { SynthDescLib.global.at(\clean_spectralBinShifter).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~sbs.notNil });

// presetStore.(\sbs);
);




// Spectral High-Pass Filter. Made by Mads Kjeldgaard.
// Activate it by providing the \hbr key a value in a pattern.
// Parameters:
// hbs | hbi | hbo | hbb
// // (NEW: hbi, hbo, hbb)
(
SynthDef(\clean_spectralHighPassFilter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	cutoff = \cutoff.kr(0.2).linlin(0.0, 1.0, 0.006, 0.48);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_BrickWall(signal[1], cutoff));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\hbr, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralHighPassFilter, [
		cutoff: ~hbr ?? { SynthDescLib.global.at(\clean_spectralHighPassFilter).controlDict[\cutoff].defaultValue },
		inputGain: ~hbi ?? { SynthDescLib.global.at(\clean_spectralHighPassFilter).controlDict[\inputGain].defaultValue },
		outputGain: ~hbo ?? { SynthDescLib.global.at(\clean_spectralHighPassFilter).controlDict[\outputGain].defaultValue },
		blend: ~hbb ?? { SynthDescLib.global.at(\clean_spectralHighPassFilter).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~hbr.notNil });

// presetStore.(\hbr);
);




// Spectral Low-Pass Filter. Made by Mads Kjeldgaard.
// Activate it by providing the \lbr key a value in a pattern.
// Parameters:
// lbr | lbi | lbo | lbb
// // (NEW: lbi, lbo, lbb)
(
SynthDef(\clean_spectralLowPassFilter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	cutoff = \cutoff.kr(0.2).linlin(0.0, 1.0, 0.0, -1.0);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_BrickWall(signal[1], cutoff));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\lbr, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralLowPassFilter, [
		cutoff: ~lbr ?? { SynthDescLib.global.at(\clean_spectralLowPassFilter).controlDict[\cutoff].defaultValue },
		inputGain: ~lbi ?? { SynthDescLib.global.at(\clean_spectralLowPassFilter).controlDict[\inputGain].defaultValue },
		outputGain: ~lbo ?? { SynthDescLib.global.at(\clean_spectralLowPassFilter).controlDict[\outputGain].defaultValue },
		blend: ~lbb ?? { SynthDescLib.global.at(\clean_spectralLowPassFilter).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~lbr.notNil });

// presetStore.(\lbr);
);




// Spectral Conformal Mapping. Made by Mads Kjeldgaard.
// Activate it by providing the \scr or sci key a value in a pattern.
// Parameters:
// scr* | scm* | sci | sco | scb
// // (NEW: sci, sco, scb)
// *scr formerly called scf, *scm formerly called img
(
SynthDef(\clean_spectralConformalMap, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	real = \real.kr(0.5).linlin(0.0, 1.0, 0.01, 2.0), imaginary = \imaginary.kr(0.5).linlin(0.0, 1.0, 0.01, 10.0);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_ConformalMap(signal[1], real, imaginary)).tanh;
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\scf, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralConformalMap, [
		real: ~scr ?? { SynthDescLib.global.at(\clean_spectralConformalMap).controlDict[\real].defaultValue },
		imaginary: ~scm ?? { SynthDescLib.global.at(\clean_spectralConformalMap).controlDict[\imaginary].defaultValue },
		inputGain: ~sci ?? { SynthDescLib.global.at(\clean_spectralConformalMap).controlDict[\inputGain].defaultValue },
		outputGain: ~sco ?? { SynthDescLib.global.at(\clean_spectralConformalMap).controlDict[\outputGain].defaultValue },
		blend: ~scb ?? { SynthDescLib.global.at(\clean_spectralConformalMap).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~scr.notNil or: ~sci.notNil });

// presetStore.(\scf);
);




// Spectral Enhancer. Made by Mads Kjeldgaard.
// Activate it by providing the \enh, \enp, \enr, or \ens key a value in a pattern.
// Parameters:
// enh | enp | enr | ens | eni | eno | enb
// // (NEW: enp, enr, ens, eni, eno, enb)
(
SynthDef(\clean_spectralEnhancer, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	enhance = \enhance.kr(0.5).linlin(0.0, 1.0, 0.0, 2.0), numPartials = \numPartials.kr(0.5).linlin(0.0, 1.0, 1, 16),
	ratio = \ratio.kr(0.5).linlin(0.0, 1.0, 1.0, 5.0), strength = \strength.kr(0.5).linlin(0.0, 1.0, 0.0, 0.99);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_SpectralEnhance(signal[1], enhance * numPartials, (enhance * ratio).max(1), (enhance * strength).abs)).tanh;
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\enh, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralEnhancer, [
		enhance: ~enh ?? { SynthDescLib.global.at(\clean_spectralEnhancer).controlDict[\enhance].defaultValue },
		numPartials: ~enp ?? { SynthDescLib.global.at(\clean_spectralEnhancer).controlDict[\numPartials].defaultValue },
		ratio: ~enr ?? { SynthDescLib.global.at(\clean_spectralEnhancer).controlDict[\ratio].defaultValue },
		strength: ~ens ?? { SynthDescLib.global.at(\clean_spectralEnhancer).controlDict[\strength].defaultValue },
		inputGain: ~eni ?? { SynthDescLib.global.at(\clean_spectralEnhancer).controlDict[\inputGain].defaultValue },
		outputGain: ~eno ?? { SynthDescLib.global.at(\clean_spectralEnhancer).controlDict[\outputGain].defaultValue },
		blend: ~enb ?? { SynthDescLib.global.at(\clean_spectralEnhancer).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~enh.notNil or: ~enp.notNil or: ~enr.notNil or: ~ens.notNil });

// presetStore.(\enh);
);




// Spectral Phase Decorrelator.
// Activate it by providing the \psd or \psb key a value in a pattern.
// Parameters:
// psd | psa | psi | pso | psb
// // (NEW: )
(
SynthDef(\clean_spectralPhaseDecorrelator, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(0.5).linlin(0.0, 1.0, -1.0, 1.0),
	depth = \depth.kr(0.1).linlin(0.0, 1.0, 0, 2pi), accumulate = \accumulate.kr;
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var numFrames = 2048;
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0].asArray.collect { |x| FFT(LocalBuf(numFrames), x) };
	signal[1] = IFFT(PV_PhaseShift(signal[1], [depth, depth.linlin(0, 2pi, 2pi, 0)], accumulate));
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\psd, { |cleanEvent|
	cleanEvent.sendSynth(\clean_spectralPhaseDecorrelator, [
		depth: ~psd ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\depth].defaultValue },
		accumulate: ~psa ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\accumulate].defaultValue },
		inputGain: ~psi ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\inputGain].defaultValue },
		outputGain: ~pso ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\outputGain].defaultValue },
		blend: ~psb ?? { SynthDescLib.global.at(\clean_spectralPhaseDecorrelator).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~psd.notNil or: ~psb.notNil });

// presetStore.(\psd);
);



// Low-Pass to High-Pass Morphing Filter.
// Activate it by providing the \lhf key a value in a pattern.
// Parameters:
// lhf | lfq | hfq | lhi | lho | lhb
// // (NEW: lfq, hfq, lhi, lho, lhb)
(
SynthDef(\clean_morphingFilter, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	cutoff = \cutoff.kr(0.5), lpResonance = \lpResonance.kr(1).clip(0.01, 1.0), hpResonance = \hpResonance.kr(1).clip(0.01, 1.0);
	var signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	var lpCutoff = cutoff.linexp(0, 0.5, 20, 10000);
	var hpCutoff = cutoff.linexp(0.5, 1, 20, 10000);
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = RLPF.ar(signal[0], lpCutoff, lpResonance);
	signal[1] = RHPF.ar(signal[1], hpCutoff, hpResonance);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\mrf, { |cleanEvent|
	cleanEvent.sendSynth(\clean_morphingFilter, [
		cutoff: ~lhf ?? { SynthDescLib.global.at(\clean_morphingFilter).controlDict[\cutoff].defaultValue }, // mrf
		lpResonance: ~lfq ?? { SynthDescLib.global.at(\clean_morphingFilter).controlDict[\lpResonance].defaultValue }, // mlq
		hpResonance: ~hfq ?? { SynthDescLib.global.at(\clean_morphingFilter).controlDict[\hpResonance].defaultValue }, // mhq
		inputGain: ~lhi ?? { SynthDescLib.global.at(\clean_morphingFilter).controlDict[\inputGain].defaultValue }, // mri
		outputGain: ~lho ?? { SynthDescLib.global.at(\clean_morphingFilter).controlDict[\outputGain].defaultValue }, // mri
		blend: ~lhb ?? { SynthDescLib.global.at(\clean_morphingFilter).controlDict[\blend].defaultValue }, // mrb
		bus: ~out
	])
}, { ~lhf.notNil});

// presetStore.(\mrf);
);




// Tremolo.
// Activate it by providing the \tre or \trd key a value in a pattern.
// Parameters:
// tor | tod | top | toi | too | tob
// // (NEW: )
(
SynthDef(\clean_tremolo, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	rate = \rate.kr(1), depth = \depth.kr(0.75).clip(0.0, 1.0), phase = \phase.kr(0.5pi).mod(2pi);
	var modulation, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	modulation = SinOsc.ar(rate, phase, depth).range(0, 1);
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0] * modulation;
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\tre, { |cleanEvent|
	cleanEvent.sendSynth(\clean_tremolo, [
		rate: ~tor ?? { SynthDescLib.global.at(\clean_tremolo).controlDict[\rate].defaultValue },
		depth: ~tod ?? { SynthDescLib.global.at(\clean_tremolo).controlDict[\depth].defaultValue },
		phase: ~top ?? { SynthDescLib.global.at(\clean_tremolo).controlDict[\phase].defaultValue },
		inputGain: ~toi ?? { SynthDescLib.global.at(\clean_tremolo).controlDict[\inputGain].defaultValue },
		outputGain: ~too ?? { SynthDescLib.global.at(\clean_tremolo).controlDict[\outputGain].defaultValue },
		blend: ~tob ?? { SynthDescLib.global.at(\clean_tremolo).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~tor.notNil or: ~tod.notNil });

// presetStore.(\tre);
);




// Auto-Pan with Sine Wave Modulation.
// Activate it by providing the \apr or \apd key a value in a pattern.
// Parameters:
// apr | apd | apl | app | api | apo | apb
// // (NEW: )
(
SynthDef(\clean_autoPan, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(1).linlin(0.0, 1.0, -1.0, 1.0),
	rate = \rate.kr(1), detune = \detune.kr, depth = \depth.kr(0.75).clip(0.0, 1.0), phase = \phase.ir.mod(4);
	var modulation, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	modulation = [LFPar.ar(rate, phase, depth).range(0, 1), LFPar.ar(rate + detune, (phase + 2).mod(4), depth).range(0, 1)];
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = signal[0] * modulation;
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\apn, { |cleanEvent|
	cleanEvent.sendSynth(\clean_autoPan, [
		rate: ~apr ?? { SynthDescLib.global.at(\clean_autoPan).controlDict[\rate].defaultValue },
		depth: ~apd ?? { SynthDescLib.global.at(\clean_autoPan).controlDict[\depth].defaultValue },
		detune: ~apl ?? { SynthDescLib.global.at(\clean_autoPan).controlDict[\detune].defaultValue },
		phase: ~app ?? { SynthDescLib.global.at(\clean_autoPan).controlDict[\phase].defaultValue },
		inputGain: ~api ?? { SynthDescLib.global.at(\clean_autoPan).controlDict[\inputGain].defaultValue },
		outputGain: ~api ?? { SynthDescLib.global.at(\clean_autoPan).controlDict[\outputGain].defaultValue },
		blend: ~apb ?? { SynthDescLib.global.at(\clean_autoPan).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~apr.notNil or: ~apd.notNil });

// presetStore.(\apn);
);




// Phaser.
// Activate it by providing the \phr or \phd key a value in a pattern.
// Parameters:
// phr | phd | pdt | pmd | phi | pho | phb
// // (NEW: )
(
SynthDef(\clean_phaser, {
	var bus = \bus.ir, inputGain = \inputGain.kr(1), outputGain = \outputGain.kr(1), blend = \blend.kr(0.5).linlin(0.0, 1.0, -1.0, 1.0),
	rate = \rate.kr(1), depth = \depth.kr(0.5).clip(0.0, 1.0), maxDelayTime = \maxDelayTime.ir(4).max(0.1), decayTime = \decayTime.kr;
	var modulation, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	modulation = LFPar.kr(rate).range(0.0088, 0.01);
	signal[0] = In.ar(bus, ~clean.numChannels) * inputGain;
	signal[1] = AllpassL.ar(signal[0], maxDelayTime, modulation, decayTime, depth);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * outputGain;
	ReplaceOut.ar(bus, signal[1])
}).add;

~clean.addModule(\phs, { |cleanEvent|
	cleanEvent.sendSynth(\clean_phaser, [
		rate: ~phr ?? { SynthDescLib.global.at(\clean_phaser).controlDict[\rate].defaultValue },
		depth: ~phd ?? { SynthDescLib.global.at(\clean_phaser).controlDict[\depth].defaultValue },
		decayTime: ~pdt ?? { SynthDescLib.global.at(\clean_phaser).controlDict[\decayTime].defaultValue },
		maxDelayTime: ~pmd ?? { SynthDescLib.global.at(\clean_phaser).controlDict[\maxDelayTime].defaultValue },
		inputGain: ~phi ?? { SynthDescLib.global.at(\clean_phaser).controlDict[\inputGain].defaultValue },
		outputGain: ~pho ?? { SynthDescLib.global.at(\clean_phaser).controlDict[\outputGain].defaultValue },
		blend: ~phb ?? { SynthDescLib.global.at(\clean_phaser).controlDict[\blend].defaultValue },
		bus: ~out
	])
}, { ~phr.notNil or: ~phd.notNil });

// presetStore.(\phs);
);




/*/*/*/* Internal Signal Routing & Summing */*/*/*/


// Internal Bus Router.
// Activate it by providing the \bsn key a value in a pattern. The value represents one of SuperClean's audio routing buses.
// Parameters:
// bsn* | bsi | bsb
// // (NEW: bsi, bsb)
// *formerly called to
(
SynthDef(\clean_busSend, {
	var internalBus = \internalBus.ir, externalBus = \externalBus.ir, inputGain = \inputGain.kr(1), routeBalance = \routeBalance.kr(1);
	var signal = In.ar(internalBus, ~clean.numChannels) * inputGain;
	OffsetOut.ar(externalBus, signal * routeBalance);
	ReplaceOut.ar(internalBus, signal * (1 - routeBalance))
}).add;

~clean.addModule(\bsn, { |cleanEvent|
	cleanEvent.sendSynth(\clean_busSend, [
		externalBus: ~clean.audioRoutingBusses.wrapAt(~bsn ?? { 0 }).index,
		inputGain: ~bsi ?? { SynthDescLib.global.at(\clean_busSend).controlDict[\inputGain].defaultValue },
		routeBalance: ~bsb ?? { SynthDescLib.global.at(\clean_busSend).controlDict[\routeBalance].defaultValue },
		internalBus: ~out ?? { SynthDescLib.global.at(\clean_busSend).controlDict[\interalBus].defaultValue }
	])
}, { ~bsn.notNil });

// presetStore.(\bsn);
);



// drive.linlin(1, 10, 0.25, 0.1, \min).poll
// Event Instance Summing Bus.
// Automatically created for each event.
// Parameters:
// ivl | ich | iat | ist | irl | iec
// // (NEW: )
(
SynthDef(\clean_instanceSumBus, {
	var input = \input.ir, output = \output.ir, amp = \amp.kr(1), gate = \gate.kr(1), attack = \attack.ir(0.001).abs,
	sustainTime = \sustainTime.ir.abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir;
	var drive = \drive.kr, gain = \gain.kr(5);

	var agc, agcDrive, agcClean, ampEnv, signal;

	agc = 0.7 - ((drive >= 2) * drive.linexp(2, 10, 0.1, 0.45));
	agcDrive = drive.linlin(1.1, 10, 0.25, 0.125, \min);
	agcDrive = agcDrive + ((drive > 1) * agcDrive.neg * 2) + ((drive <= 1) * 0.0625);
	agcClean = drive.linlin(1.1, 10, 1, 0.375, \min) + ((drive <= 1) * 0.25);

	ampEnv = Env.linen(attack, sustainTime, release, 1, ampEnvCurve).kr(Done.freeGroup, gate);
	// ampEnv = Env.asr(attack, 1.0, release, ampEnvCurve).kr(Done.freeGroup, gate);

	signal = In.ar(input, ~clean.numChannels);
	signal = (
		((signal * drive * gain).tanh * (amp * agcDrive) * (drive > 0)) +
		(signal * (amp * agcClean) * (1 - drive)) *
		agc
	);

	signal = LeakDC.ar(signal);
	signal = signal * ampEnv;
	OffsetOut.ar(output, signal)
}).add;

/* eventually added here, currently in CleanEvent
~clean.addModule(\sum, { |cleanEvent|
	cleanEvent.sendGateSynth(\clean_instanceSumBus [
				input: aux.synthBus.index, // read from synth bus, which is reused
				output: aux.dryBus.index, // write to aux dry bus
				amp: ~ivl ?? { SynthDescLib.global.at(\clean_instanceSumBus).controlDict[\amp].defaultValue },
				attack: ~iat ?? { SynthDescLib.global.at(\clean_instanceSumBus).controlDict[\attack].defaultValue },
				sustainTime: ~ist ?? { ~sustain },
				release: ~irl ?? { SynthDescLib.global.at(\clean_instanceSumBus).controlDict[\release].defaultValue },
				ampEnvCurve: ~iec ?? { SynthDescLib.global.at(\clean_instanceSumBus).controlDict[\ampEnvCurve].defaultValue },
				drive: ~ich ?? { SynthDescLib.global.at(\clean_instanceSumBus).controlDict[\drive].defaultValue },
				gain: ~ign ?? { SynthDescLib.global.at(\clean_instanceSumBus).controlDict[\gain].defaultValue }
	])
});

presetStore.(\sum)
*/
);
)