// Updated Global Effects
// Currently deactivated until after properly testing all units.


/*
NOTES/TO DO:




.add or .store SynthDefs

The order and arg names are currently set in CleanAux.sc: initDefaultGlobalEffects, ~ line 56.
Order is mostly unimportant (except for outputMonitor and rms)

Some arg name translation is happening in CleanEvent.sc: finaliseParameters, ~ line 171.

Add parameters to mainOutput limiter?

input- & output- Gains: lag on multiplier necessary? eg: .lag(LFNoise1.kr(1).range(0.01, 0.02)) or .lag(0.01)

AmpEnv: are these actually necessary?

Mir: modify so that it is just a convolution effect -- meaning that IR's can be flexibly swapped.
-- add function for IR preloading, for simplified address, etc.

rename outBus : outputBus
rename dryBus : instanceBus : globalDryBus
rename effectBus : globalBus : globalWetBus
rename synthBus : sourceBus : instanceBus

Is there a real use for \clean_rms? Remove?

*/

/*
(
/*/*/*/* Routing and Analysis */*/*/*/


// Main Output, with limiter.
// It is always active.
// Parameters:
// ocg | oeg | oog | osb | osd | oat | osl | orl | oec
// // (NEW: ocg, oeg, oog, osb, osd, oat, osl, orl, oec)
(
SynthDef(\clean_outputMonitor, {
	var instanceBus = \instanceBus.ir, globalBus = \globalBus.ir, outputBus = \outputBus.kr,
	instanceBusGain = \instanceBusGain.kr(1).abs, globalBusGain = \globalBusGain.kr(1).abs,
	outputGain = \outputGain.kr(1), blend = \blend.kr(0.5).linlin(0.0, 1.0, -1.0, 1.0), gate = \gate.kr(1),
	attack = \attack.ir(0.01).abs, sustainLevel = \sustainLevel.ir(1).abs, release = \release.ir(1).abs,
	ampEnvCurve = \ampEnvCurve.ir(-4), drive = \drive.kr.clip(0.0, 1.0);
	var post, ampEnv, instanceSignal, globalSignal, signal;
	ampEnv = Env.asr(attack, sustainLevel, release, ampEnvCurve).kr(Done.freeSelf, gate);
	instanceSignal = In.ar(instanceBus, ~clean.numChannels) * instanceBusGain; // dry, pre-global effects
	globalSignal = In.ar(globalBus, ~clean.numChannels) * globalBusGain; // wet, post-global effects
	signal = XFade2.ar(instanceSignal, globalSignal, blend);
	post = if(SuperClean.postBadValues) { 2 } { 0 };
	signal = Select.ar(CheckBadValues.ar(signal, post: post) > 0, [signal, DC.ar(0)]);
	signal = Limiter.ar(signal);
	signal = (signal.tanh * outputGain * drive) + (signal * outputGain * (1 - drive));
	signal = signal * ampEnv;
	CleanPause.ar(signal, graceTime: 4);
	Out.ar(outputBus, signal)
}).add;

/*
instanceBusGain: ~ocg,
globalBusGain: ~oeg,
outputGain: ~oog,
blend: ~osb, // output signal blend
drive: ~osd,
attack: ~oat
sustainLevel: ~osl,
release: ~orl
ampEnvCurve: ~oec
*/
/*
~clean.globalEffectEvent.[cleanName] = GlobalCleanEffect(\clean_outputMonitor, [
	\argName: ~clnArg, // etc
]).alwaysRun_(true)

*/
// presetStore.(\mmo);
);




// Pre-Main Output RMS Meter.
// It has no signal output, and is used just for level indication. Input gains are same keys as \clean_outputMonitor.
// Parameters:
// ocg | oeg | oog | osb | rmsReplyRate | rmsPeakLag | auxIndex
// // (NEW: ocg, oeg, oog, osb)
(
SynthDef(\clean_rmsMeter, {
	var instanceBus = \instanceBus.ir, globalBus = \globalBus.ir, outputBus = \outputBus.kr,
	instanceBusGain = \instanceBusGain.kr(1).abs, globalBusGain = \globalBusGain.kr(1).abs,
	outputGain = \outputGain.kr(1), blend = \blend.kr(0.5).linlin(0.0, 1.0, -1.0, 1.0),
	gate = \gate.kr(1), rmsReplyRate = \rmsReplyRate.kr, rmsPeakLag = \rmsPeakLag.kr, auxIndex = \auxIndex.kr;
	var instanceSignal, globalSignal, signal;
	instanceSignal = In.ar(instanceBus, ~clean.numChannels) * instanceBusGain; // dry, pre-global effects
	globalSignal = In.ar(globalBus, ~clean.numChannels) * globalBusGain; // wet, post-global effects
	signal = XFade2.ar(instanceSignal, globalSignal, blend);
	CleanPause.ar(signal, graceTime: 4);
	SendPeakRMS.kr(signal, rmsReplyRate, rmsPeakLag, '/rms', auxIndex)
}).add;

/*
instanceBusGain: ~ocg,
globalBusGain: ~oeg,
outputGain: ~oog,
blend: ~osb, // output signal blend

*/
/*
~clean.globalEffectEvent.[cleanName] = GlobalCleanEffect(\clean_rmsMeter, [
	\argName: ~clnArg, // etc
]).alwaysRun_(true)

*/
// presetStore.(\rms);
);




/*/*/*/* Effects */*/*/*/


// Delay.
// Activate it by providing the \dla key a value in a pattern
// Parameters:
// dla | dlt | dlf | dlp | dli | dlb | dat | dsl | drl | dec
// // (NEW: dlp, dli, dlb, dat, dsl, drl, dec)
(
SynthDef(\clean_delay, {
	var instanceBus = \instanceBus.ir, globalBus = \globalBus.ir, inputGain = \inputGain.kr(1),
	outputGain = \outputGain.kr(1, 0.01, true), blend = \blend.kr(0.5, 0.0625, true).linlin(0.0, 1.0, -1.0, 1.0), gate = \gate.kr(1),
	attack = \attack.ir(0.01).abs, sustainLevel = \sustainLevel.ir(1).abs, release = \release.ir(1).abs,
	ampEnvCurve = \ampEnvCurve.ir(-4), feedback = \feedback.kr.abs.max(0), delayTime = \delayTime.kr(0.125),
	pan = \pan.kr, timeLock = \timeLock.kr, cyclesPerSecond = \cyclesPerSecond.kr(1);
	var maxDelayTime = 16;
	var ampEnv, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	delayTime = delayTime * if(timeLock, reciprocal(cyclesPerSecond), 1);
	delayTime = delayTime.clip(0, maxDelayTime);
	ampEnv = Env.asr(attack, sustainLevel, release, ampEnvCurve).kr(Done.freeSelf, gate);
	signal[0] = In.ar(instanceBus, ~clean.numChannels) * inputGain.lag(LFNoise1.kr(1).range(0.01, 0.02));
	signal[1] = SwitchDelay.ar(signal[0], 0, 1, delayTime, feedback, maxDelayTime);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * ampEnv * outputGain;
	CleanPause.ar(signal[1], graceTime: 4);
	OffsetOut.ar(globalBus, signal[1])
}).add;

/*

delayTime: ~dlt,
feedback: ~dlf,
inputGain: ~dli,
outputGain: ~dla,
blend: ~dlb,
pan: ~dlp
attack: ~dat
sustainLevel: ~dsl,
release: ~drl
ampEnvCurve: ~dec
timeLock: ~dtl,
cyclesPerSecond: ~cps,

*/
/*
~clean.globalEffectEvent.[cleanName] = GlobalCleanEffect(\clean_delay, [
	\argName: ~clnArg, // etc
]).alwaysRun_(true)

*/
// presetStore.(\dly);
);


/*
SynthDef ("tap", {
|dryBus, effectBus, gate = 1,  wow = 1, dropOuts = 1 |
var in, del, sig, feed, svaj, amp;
in = In.ar(dryBus, ~clean.numChannels);
in = tanh(in * 0.5);
feed = in;
amp = (LFNoise1.ar(15).range(0.8,1.1) * LFNoise1.ar(17).range(0.1,20).clip(0.3,1).lag(0.05));
feed = feed * dropOuts.if(amp,1);
svaj = LFNoise1.ar([2,9],[0.0011, 0.001]).sum.lag(0.4);
svaj = svaj - svaj.clip2(0.0007);
svaj = svaj * wow;
del = DelayL.ar(HPF.ar(feed, 10).tanh, 2.0, 0.002 + svaj);
sig = LeakDC.ar(del);
Out.ar(effectBus, del);
}, [\ir, \ir]).add;
*/


// Reverb. Based on the work of Jost Muxfeld and James McCartney.
// Activate it by providing the \rin or \rev key a value in a pattern
// Parameters:
// rin | rev | rdc | rvp | rvb | rvo | rat | rsl | rrl | rec
// // (NEW: rvp, rvb, rvo, rat, rsl, rrl, rec)
(
SynthDef(\clean_reverb, {
	var instanceBus = \instanceBus.ir, globalBus = \globalBus.ir, inputGain = \inputGain.kr(1),
	outputGain = \outputGain.kr(1, 0.01, true), blend = \blend.kr(0.5, 0.0625, true).linlin(0.0, 1.0, -1.0, 1.0), gate = \gate.kr(1),
	attack = \attack.ir(0.01).abs, sustainLevel = \sustainLevel.ir(1).abs, release = \release.ir(1).abs,
	ampEnvCurve = \ampEnvCurve.ir(-4), size = \size.kr(0.1, 0.02, true).linexp(0.0, 1.0, 0.01, 0.98),
	decayTime = \decayTime.kr(2);
	var ampEnv, signal = Array.newClear(3); // array index: [0] - in/clean, [1] - effect/main, [2] - feedback loop
	ampEnv = Env.asr(attack, sustainLevel, release, ampEnvCurve).kr(Done.freeSelf, gate);
	signal[0] = Mix(In.ar(instanceBus, ~clean.numChannels)) * inputGain.lag(LFNoise1.kr(1).range(0.01, 0.02));
	4.do { signal[1] = AllpassN.ar(signal[0], 0.03, { Rand(0.005, 0.02) }.dup(~clean.numChannels), (decayTime * 0.5).max(0.01)) };
	signal[2] = LocalIn.ar(~clean.numChannels) * { size + Rand(0, 0.05) }.dup(~clean.numChannels);
	signal[2] = OnePole.ar(signal[2], 0.5);
	signal[2] = AllpassN.ar(signal[2], 0.05, { Rand(0.01, 0.05) }.dup(~clean.numChannels), decayTime);
	signal[2] = DelayN.ar(signal[2], 0.3, [0.19, 0.26] + { Rand(-0.003, 0.003) }.dup(2));
	signal[2] = AllpassN.ar(signal[2], 0.05, { Rand(0.03, 0.15) }.dup(~clean.numChannels), decayTime);
	signal[2] = signal[2] + signal[1];
	signal[2] = LeakDC.ar(signal[2]);
	LocalOut.ar(signal[2]);
	signal[1] = signal[2];
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * ampEnv * outputGain;
	CleanPause.ar(signal[1], graceTime: 4);
	OffsetOut.ar(globalBus, signal[1])
}).add;

/*

size: ~rev,
decayTime: ~rdc,
inputGain: ~rin, // rvi
outputGain: ~rvo,
blend: ~rvb,
pan: ~rvp
attack: ~rat
sustainLevel: ~rsl,
release: ~rrl
ampEnvCurve: ~rec


*/
/*
~clean.globalEffectEvent.[cleanName] = GlobalCleanEffect(\clean_reverb, [
	\argName: ~clnArg, // etc
]).alwaysRun_(true)

*/
// presetStore.(\rev);
);




// Cavernous Reverb.
// Activate it by providing the \cav key a value in a pattern
// Parameters:
// cav | cai | cvt | cvd | cvl* | cid | cvs | cve | cda | cvp | cvb | cvo | cat | csl | crl | cec
// // (NEW: cid, cvs, cve, cda, cvp, cvb, cvo, cat, csl, crl, cec)
// *cvl range extended. (0.5 is equivalent to past 1)
(
SynthDef(\clean_caveVerb, {
	var instanceBus = \instanceBus.ir, globalBus = \globalBus.ir, inputGain = \inputGain.kr(1, 0.5, true),
	outputGain = \outputGain.kr(1, 0.5, true), blend = \blend.kr(0.5, 0.5, true).linlin(0.0, 1.0, -1.0, 1.0),
	gate = \gate.kr(1), attack = \attack.ir(0.01).abs, sustainLevel = \sustainLevel.ir(1).abs, release = \release.ir(1).abs,
	ampEnvCurve = \ampEnvCurve.ir(-4), reverbTime = \reverbTime.kr(1, 0.5, true).linlin(0.0, 1.0, 0.001, 30),
	damping = \damping.kr(0.5, 0.5, true).clip(0.0, 1.0), cutoff = \cutoff.kr(0.5, 0.5, true).linexp(0.0, 1.0, 100, 10000),
	inputDamping = \inputDamping.kr(0.5, 0.5, true).clip(0.0, 1.0), stereoSpread = \stereoSpread.kr(15, 0.5, true),
	earlyReflections = \earlyReflections.kr(0.7, 0.5, true), decayAmp = \decayAmp.kr(0.5, 0.5, true);
	var ampEnv, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	ampEnv = Env.asr(attack, sustainLevel, release, ampEnvCurve).kr(Done.freeSelf, gate);
	signal[0] = Mix(In.ar(instanceBus, ~clean.numChannels)) * inputGain;
	signal[1] = GVerb.ar(signal[0], 250, reverbTime, damping, inputDamping, stereoSpread, 0, earlyReflections, decayAmp);
	signal[1] = LPF.ar(signal[1], cutoff);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * ampEnv * outputGain.neg;
	CleanPause.ar(signal[1], graceTime: 4);
	OffsetOut.ar(globalBus, signal[1])
}).add;
/*

reverbTime: ~cvt,
damping: ~cvd,
inputGain: ~cai,
outputGain: ~cav,
inputDamping: ~cid,
stereoSpread: ~cvs,
earlyReflections: ~cve,
decayAmp: ~cda,
blend: ~cvb,
pan: ~cvp,
attack: ~cat,
sustainLevel: ~csl,
release: ~crl,
ampEnvCurve: ~cec


*/
/*
~clean.globalEffectEvent.[cleanName] = GlobalCleanEffect(\clean_caveVerb, [
	\argName: ~clnArg, // etc
]).alwaysRun_(true)

*/
// presetStore.(\cav);
);




// Convolution Effect.
// Activate it by providing the \mir key a value in a pattern
// Parameters:
// mir | mii | mil | mig | mib | mip | mat | msl | mrl | mec
// // (NEW: mil, mim, mib, mip, mat, msl, mrl, mec)
(
~path = Main.packages.asDict.at('SuperClean') +/+ "/clean-samples/mmd/mir/mir4.wav";
// ~path = Main.packages.asDict.at('SuperClean') +/+ "/SoundFiles/ImpulseResponses/mir4.wav";
~ezConvX = EZConvX(~path);
SynthDef(\clean_convolution, {
	var instanceBus = \instanceBus.ir, globalBus = \globalBus.ir, inputGain = \inputGain.kr(1, 0.5, true),
	outputGain = \outputGain.kr(1, 0.5, true), blend = \blend.kr(0.5, 0.5, true).linlin(0.0, 1.0, -1.0, 1.0),
	gate = \gate.kr(1), attack = \attack.ir(0.01).abs, sustainLevel = \sustainLevel.ir(1).abs, release = \release.ir(1).abs,
	ampEnvCurve = \ampEnvCurve.ir(-4), ampBalance = \ampBalance.kr(0.1), convolutionGain = \convolutionGain.kr(0.0625);
	var ampEnv, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	ampEnv = Env.asr(attack, sustainLevel, release, ampEnvCurve).kr(Done.freeSelf, gate);
	signal[0] = Mix(In.ar(instanceBus, ~clean.numChannels)) * inputGain;
	signal[1] = ~ezConvX.ar(signal[0], ampBalance, convolutionGain);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * ampEnv * outputGain.neg;
	CleanPause.ar(signal[1], graceTime: 4);
	OffsetOut.ar(globalBus, signal[1])
}).add;
/*

inputGain: ~mii, // cvi
outputGain: ~mir, // cvo
blend: ~mib, // cvb
pan: ~mip, //cvp
attack: ~mat, // cva
sustainLevel: ~msl, // cvs
release: ~mrl, // cvl
ampEnvCurve: ~mec,// cvc
ampBalance: ~mil, // cvl
convolutionGain: ~mig // cvg

*/
/*
~clean.globalEffectEvent.[cleanName] = GlobalCleanEffect(\clean_convolution, [
	\argName: ~clnArg, // etc
]).alwaysRun_(true)

*/
// presetStore.(\mir);
);




// Hall Reverb. Built around Nathan Ho's NHHall UGen from sc3-plugins.
// Activate it by providing the \hal key a value in a pattern
// Parameters:
// hal | rts | edf | ldf | hhp | hlp | hvh | hvl | hlr | hhr | hab | hap | hai | hat | hsl | hrl | hec
// // (NEW: hvh, hvl, hlr, hhr, hab, hap, hat, hsl, hrl, hec)
(
SynthDef(\clean_hallReverb, {
	var instanceBus = \instanceBus.ir, globalBus = \globalBus.ir, inputGain = \inputGain.kr(1, 0.0625, true),
	outputGain = \outputGain.kr(1, 0.0625, true), blend = \blend.kr(0.5, 0.0625, true).linlin(0.0, 1.0, -1.0, 1.0),
	gate = \gate.kr(1), attack = \attack.ir(0.01).abs, sustainLevel = \sustainLevel.ir(1).abs, release = \release.ir(1).abs,
	ampEnvCurve = \ampEnvCurve.ir(-4), decayTime = \decayTime.kr(1, 0.0625, true).abs, stereoSpread = \stereoSpread.kr(0.5, 0.5, true),
	hpCutoff = \hpCutoff.kr(20, 0.0625, true).clip(20, 20000), lpCutoff = \lpCutoff.kr(20000, 0.0625, true).clip(20, 20000),
	verbHPCutoff = \verbHPCutoff.kr(200, 0.0625, true), verbLPCutoff = \verbLPCutoff.kr(4000, 0.0625, true),
	lowDecayRatio = \lowDecayRatio.kr(0.5, 0.0625, true), highDecayRatio = \highDecayRatio.kr(0.5, 0.0625, true),
	earlyDiffusion = \earlyDiffusion.kr(0.5, 0.0625, true).clip(0.0, 1.0), lateDiffusion = \lateDiffusion.kr(0.5, 0.0625, true).clip(0.0, 1.0),
	lateDiffusionModRate = \lateDiffusionModRate.kr(0, 0.0625, true).clip(0.0, 1.0),
	lateDiffusionModDepth = \lateDiffusionModDepth.kr(0, 0.0625, true).clip(0.0, 1.0);
	var ampEnv, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	ampEnv = Env.asr(attack, sustainLevel, release, ampEnvCurve).kr(Done.freeSelf, gate);
	signal[0] = Mix(In.ar(instanceBus, ~clean.numChannels)) * inputGain;
	signal[1] = HPF.ar(signal[0], hpCutoff);
	signal[1] = LPF.ar(signal[1], lpCutoff);
	signal[1] = signal[1].asArray.collect { |sig|
		NHHall.ar(Pan2.ar(sig),
			decayTime,
			stereoSpread,
			verbHPCutoff,
			lowDecayRatio,
			verbLPCutoff,
			highDecayRatio,
			earlyDiffusion,
			lateDiffusion,
			lateDiffusionModRate,
			lateDiffusionModDepth
		);
	};
	signal[1] = LeakDC.ar(signal[1]);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * ampEnv * outputGain.lag(0.0625).neg;
	CleanPause.ar(signal[1], graceTime: 4);
	OffsetOut.ar(globalBus, signal[1])
}).add;
/*

inputGain: ~hai,
outputGain: ~hal,
blend: ~hab,
pan: ~hap,
attack: ~hat,
sustainLevel: ~hsl,
release: ~hrl,
ampEnvCurve: ~hec,
decayTime: ~rts, // hdt or hdc or had
hpCutoff: ~hhp,
lpCutoff: ~hlp,
verbHPCutoff: ~hvh,
verbLPCutoff: ~hvl,
lowDecayRatio: ~hlr,
highDecayRatio: ~hhr,
earlyDiffusion: ~edf,
lateDiffusion: ~ldf


*/
/*
~clean.globalEffectEvent.[cleanName] = GlobalCleanEffect(\clean_hallReverb, [
	\argName: ~clnArg, // etc
]).alwaysRun_(true)

*/
// presetStore.(\hal);
);


// Drive/Character.
// Activate it by providing the \tnh key a value in a pattern
// Parameters:
// tnh | tnb | tng | tna | tcg | teg | tnm | tnp | tat | tsl | trl | tec
// // (NEW: tcg, teg, tnm, tnp, tat, tsl, trl, tec)
(
SynthDef(\clean_character, {
	var instanceBus = \instanceBus.ir, globalBus = \globalBus.ir, instanceBusGain = \instanceBusGain.kr(1, 0.0625, true),
	globalBusGain = \globalBusGain.kr(1, 0.0625, true),	outputGain = \outputGain.kr(1, 0.0625, true),
	blend = \blend.kr(1, 0.0625, true).linlin(0.0, 1.0, -1.0, 1.0), gate = \gate.kr(1), attack = \attack.ir(0.01).abs,
	sustainLevel = \sustainLevel.ir(1).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(-4), gain = \gain.kr(1),
	preCutoff = \preCutoff.kr(20000, 0.0625, true).clip(20, 20000), postCutoff = \postCutoff.kr(20000, 0.0625, true).clip(20, 20000);
	var ampEnv, instanceSignal, globalSignal, signal = Array.newClear(2); // array index: [0] - in/clean, [1] - effect/main
	ampEnv = Env.asr(attack, sustainLevel, release, ampEnvCurve).kr(Done.freeSelf, gate);
	instanceSignal = In.ar(instanceBus, ~clean.numChannels) * instanceBusGain; // dry, pre-global effects
	globalSignal = In.ar(globalBus, ~clean.numChannels) * globalBusGain; // wet, post-global effects
	signal[0] = instanceSignal + globalSignal;
	signal[1] = LPF.ar(signal[0], preCutoff);
	signal[1] = (signal[1] * gain).tanh;
	signal[1] = LPF.ar(signal[1], postCutoff);
	signal[1] = LeakDC.ar(signal[1]);
	signal[1] = XFade2.ar(signal[0], signal[1], blend);
	signal[1] = signal[1] * ampEnv * outputGain;
	CleanPause.ar(signal[1], graceTime: 4);
	OffsetOut.ar(globalBus, signal[1])
}).add;
/*

instanceBusGain: ~tcg,
globalBusGain: ~teg,
outputGain: ~tnh,
blend: ~tnm,
pan: ~tnp,
attack: ~tat,
sustainLevel: ~tsl,
release: ~trl,
ampEnvCurve: ~tec,
gain: ~tng,
preCutoff: ~tnb, // tcb
postCutoff: ~tna, // tca





*/
/*
~clean.globalEffectEvent.[cleanName] = GlobalCleanEffect(\clean_character, [
	\argName: ~clnArg, // etc
]).alwaysRun_(true)

*/
// presetStore.(\tnh);
);
)
*/