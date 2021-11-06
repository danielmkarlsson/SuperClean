/*

brief description of this doc

*/



/*
questions & to do::
questions & to do::



Move sample player into this file

Should atk / rel / crv rates be set to kr if retriggering is a consideration?

Add \det to each synth def?

Test: make sure all relative amplitudes of the synths are similar

Sample player name this name corresponds to line 263 of CleanSoundLibrary.sc. Remove hard coding of SynthDef name from there, and pass as an argument when the function is called
// Perhaps achievable by using ~clean.soundLibrary.addBuffer to add sample player SynthDef.
// // see CleanSoundLibrary.sc for more


Add timeScale array to \fmx.

Synths with arrays for specific parameter: add additional "global" parameter which allows all of them to be set simultaneously?

Do no add out, amp, & pan conversions to Dictionaries for now. TBD why this breaks things. (out is obvious, but the other two aren't)
*/

(
/*
// Sample player.
// Call it by providing \folderNameOfLoadedSamples as a value to the \snd key in a pattern, and specify which sample by providing a number to the \num key.
// Parameters:
// num | bgn | len* | spd | lop | rtg | fdt |
// amp | pan | atk | rel | crv | gate | tsc | bnd | bnt | bno | bnc | freq | out
// // (NEW: len, lop, rtg, fdt, amp, atk, rel, crv, gate, bnd, bnt, bno, bnc)
* formerly end (now a time value, rather than position, set -1 for total sample length)

*/



// Pitch-warping synth in the style of Gabor Lazar.
// Call it by providing \add as a value to the \snd key in a pattern, and by providing an array for frequency or pitch (or any other similar key).
// Parameters:
// ada | adr | slw | adc*
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq
// // (NEW: gate, tsc*, bnd, bnt, bno, bnc)
// *adc no longer for vol env- now for slideEnv
// *tsc formerly named sustain
(
SynthDef(\cleanS_warp, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
	bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
	attack = \attack.ir(0.001).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(1), gate = \gate.tr(1),
	timeScale = \timeScale.kr(1).abs;
	var freqUpTime = \freqUpTime.ir(0.001).abs, freqDownTime = \freqDownTime.ir(1).abs, downTimeOffset = \downTimeOffset.ir(0.001).abs,
	freqEnvCurve = \freqEnvCurve.ir(30);

	var bendEnv = Array.newClear(2), bentFreq, ampEnv = Array.newClear(2), signal;

	bendEnv[0] = Env([0, 1, 0], [freqUpTime, (freqDownTime + downTimeOffset).max(0)], [freqEnvCurve.neg, freqEnvCurve]).kr(0, gate);
	bendEnv[1] = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate); // pitch bend
	bentFreq = (freq * bendEnv[0] * bendEnv[1]).clip(20, 20000);

	ampEnv[0] = Env.perc(freqUpTime, freqDownTime + 0.0001, 1, ampEnvCurve).kr(0, gate); // useful?
	ampEnv[1] = Env.linen(attack, (timeScale - 1).max(0), release, 1, ampEnvCurve).kr(Done.freeSelf, gate, timeScale);

	signal = SinOsc.ar(bentFreq);

	signal = signal * amp * (ampEnv[0].max(0.2) * 0.5) * ampEnv[1] * AmpComp.kr(freq, 40, 0.3); // ampEnv[0]??
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\add, (
	instrument: \cleanS_warp,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\bendCurve].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\timeScale].defaultValue } },
	freqUpTime: { ~ada ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\freqUpTime].defaultValue } },
	freqDownTime: { ~adr ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\freqDownTime].defaultValue } },
	downTimeOffset: { ~slw ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\downTimeOffset].defaultValue } },
	freqEnvCurve: { ~adc ?? { SynthDescLib.global.at(\cleanS_warp).controlDict[\freqEnvCurve].defaultValue } }
));
);



// Four operator Frequency Modulation synth.
// Call it by providing \fmx as a value to the \snd key in a pattern.
// Parameters:
// hr1 | hr2 | hr3 | hr4 | mi1 | mi2 | mi3 | mi4 | en1 | en2 | en3 | en4
// er1 | er2 | er3 | er4 | cu1 | cu2 | cu3 | cu4 | det | uni
// amp | pan | atk | rel | crv | gate | tsc | bnd | bnt | bno | bnc | freq | out
// // (NEW: uni, gate, tsc*, am1-4, er1-4, bnd, bnt, bno, bnc)
// *tsc formerly named sustain
(
SynthDef(\cleanS_fmx, {
	var out = \out.ir, amp = [\amp1.kr(1), \amp2.kr(1), \amp3.kr(1), \amp4.kr(1), \amp.kr(0.3)], pan = \pan.kr, freq = \freq.kr(440).abs,
	bend = \bend.kr.clip(-1, 1), bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs,
	bendCurve = \bendCurve.ir, attack = [\attack1.ir.abs, \attack2.ir.abs, \attack3.ir.abs, \attack4.ir.abs], gate = \gate.tr(1),
	timeScale = \timeScale.kr(1).abs, release = [\release1.ir(1).abs, \release2.ir(1).abs, \release3.ir(1).abs, \release4.ir(1).abs],
	ampEnvCurve = [\ampEnvCurve1.ir, \ampEnvCurve2.ir, \ampEnvCurve3.ir, \ampEnvCurve4.ir];
	var unisonBend = \unisonBend.kr(1),	modIndex = [\modIndex1.kr(0.8), \modIndex2.kr(4), \modIndex3.kr(0.5), \modIndex4.kr(1)],
	harmonicityRatio = [\harmonicityRatio1.kr(0).abs, \harmonicityRatio2.kr(1).abs, \harmonicityRatio3.kr(2).abs, \harmonicityRatio4.kr(1).abs],
	detune = \detune.kr;

	var bendEnv, bentFreq, ampEnv = Array.newClear(4), signal, modComp, modulatorBend;

	modComp = freq.explin(20, 20000, 1, 0.01);
	bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	bentFreq = (freq * bendEnv).clip(20, 20000);
	modulatorBend = (bentFreq * unisonBend) + (freq * (1 - unisonBend)); // dry/wet control for bendEnv on modulators

	ampEnv[0] = Env.perc(attack[0], release[0] - attack[0], amp[0], ampEnvCurve[0]).kr(Done.freeSelf, gate, timeScale);
	ampEnv[1] = Env.perc(attack[1], release[1] - attack[1], amp[1], ampEnvCurve[1]).kr(0, gate, timeScale);
	ampEnv[2] = Env.perc(attack[2], release[2] - attack[2], amp[2], ampEnvCurve[2]).kr(0, gate, timeScale);
	ampEnv[3] = Env.perc(attack[3], release[3] - attack[3], amp[3], ampEnvCurve[3]).kr(0, gate, timeScale);

	signal = SinOscFB.ar(bentFreq * harmonicityRatio[3], modIndex[0] * modComp, modIndex[3] * modComp) * ampEnv[3];
	signal = SinOsc.ar(modulatorBend * harmonicityRatio[2], signal + [0, pi/2], modIndex[2] * modComp) * ampEnv[2];
	signal = SinOsc.ar(modulatorBend * harmonicityRatio[1], signal, modIndex[1] * modComp) * ampEnv[1];
	signal = SinOsc.ar(modulatorBend * harmonicityRatio[0] + [detune.neg, detune], signal) * ampEnv[0];

	signal = signal * (amp[4] * 0.7) * AmpCompA.kr(bentFreq, 17.323914436055);
	signal = signal.tanh;

	signal = LeakDC.ar(signal);
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\fmx, (
	instrument: \cleanS_fmx,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\bendCurve].defaultValue } },
	amp1: { ~am1 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\amp1].defaultValue } },
	amp2: { ~am2 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\amp2].defaultValue } },
	amp3: { ~am3 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\amp3].defaultValue } },
	amp4: { ~am4 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\amp4].defaultValue } },
	attack1: { ~en1 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\attack1].defaultValue } },
	attack2: { ~en2 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\attack2].defaultValue } },
	attack3: { ~en3 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\attack3].defaultValue } },
	attack4: { ~en4 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\attack4].defaultValue } },
	release1: { ~er1 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\release1].defaultValue } },
	release2: { ~er2 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\release2].defaultValue } },
	release3: { ~er3 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\release3].defaultValue } },
	release4: { ~er4 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\release4].defaultValue } },
	ampEnvCurve1: { ~cu1 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\ampEnvCurve1].defaultValue } },
	ampEnvCurve2: { ~cu2 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\ampEnvCurve2].defaultValue } },
	ampEnvCurve3: { ~cu3 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\ampEnvCurve3].defaultValue } },
	ampEnvCurve4: { ~cu4 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\ampEnvCurve4].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\timeScale].defaultValue } },
	detune: { ~det ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\detune].defaultValue } },
	unisonBend: { ~uni ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\unisonBend].defaultValue } },
	modIndex1: { ~mi1 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\modIndex1].defaultValue } },
	modIndex2: { ~mi2 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\modIndex2].defaultValue } },
	modIndex3: { ~mi3 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\modIndex3].defaultValue } },
	modIndex4: { ~mi4 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\modIndex4].defaultValue } },
	harmonicityRatio1: { ~hr1 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\harmonicityRatio1].defaultValue } },
	harmonicityRatio2: { ~hr2 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\harmonicityRatio2].defaultValue } },
	harmonicityRatio3: { ~hr3 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\harmonicityRatio3].defaultValue } },
	harmonicityRatio4: { ~hr4 ?? { SynthDescLib.global.at(\cleanS_fmx).controlDict[\harmonicityRatio4].defaultValue } }
));
);



// A two operator Phase Distortion synth. This builds on the work of Nathan Ho. https://nathan.ho.name/posts/ixa-synthesis/
// Call it by providing \ixa as a value to the \snd key in a pattern.
// Parameters:
// bes | ber | abs | abr | ths | thr
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq | out
// // (NEW: gate (and tsc on ampEnv))
// *tsc formerly named sustain
(
SynthDef(\cleanS_ixa, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
	bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
	attack = \attack.ir(0.001).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir,
	gate = \gate.tr(1), timeScale = \timeScale.kr(1).abs;
	var speed = [\slopeBelowSpeed.kr(2).abs, \slopeAboveSpeed.kr(2).abs, \thresholdSpeed.kr(2).abs],
	range = [\slopeBelowRange.kr(1).abs, \slopeAboveRange.kr(1).abs, \thresholdRange.kr(1).abs];

	var bendEnv, bentFreq, ampEnv, signal, phase, slopeBelow, slopeAbove, threshold;

	bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	bentFreq = (freq * bendEnv).clip(20, 20000);

	ampEnv = Env.perc(attack, release, amp, ampEnvCurve).kr(Done.freeSelf, gate, timeScale);

	slopeBelow = LFNoise2.kr(speed[0]).range(0, range[0]);
	slopeAbove = LFNoise2.kr(speed[1]).range(0, range[1]);
	threshold = LFNoise2.kr(speed[2]).range(0, range[2]);

	phase = Phasor.ar(0, bentFreq / SampleRate.ir, 0, 1);
	phase = Select.ar(phase > threshold, [phase * slopeAbove, threshold + ((phase - threshold) * slopeBelow)]);

	signal = SinOsc.ar(0, phase * 2pi);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\ixa, (
	instrument: \cleanS_ixa,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? {SynthDescLib.global.at(\cleanS_ixa).controlDict[\bendCurve].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\timeScale].defaultValue } },
	slopeBelowSpeed: { ~bes ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\slopeBelowSpeed].defaultValue } },
	slopeBelowRange: { ~ber ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\slopeBelowRange].defaultValue } },
	slopeAboveSpeed: { ~abs ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\slopeAboveSpeed].defaultValue } },
	slopeAboveRange: { ~abr ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\slopeAboveRange].defaultValue } },
	thresholdSpeed: { ~ths ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\thresholdSpeed].defaultValue } },
	thresholdRange: { ~thr ?? { SynthDescLib.global.at(\cleanS_ixa).controlDict[\thresholdRange].defaultValue } }
));
);



// Sine wave oscillator synth.
// Call it by providing \sin as a value to the \snd key in a pattern.
// Parameters:
// iph
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq | out
// // (NEW: gate (and tsc on ampEnv))
// *tsc formerly named sustain
(
SynthDef(\cleanS_sine, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440), bend = \bend.kr.clip(-1, 1),
	bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
	attack = \attack.ir(0.001).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(-8), gate = \gate.tr(1),
	timeScale = \timeScale.kr(1).abs;
	var initPhase = \initPhase.ir.clip(0, 1);

	var bendEnv, bentFreq, ampEnv, signal;

	bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	bentFreq = (freq * bendEnv).clip(20, 20000);

	ampEnv = Env.perc(attack, release, amp, ampEnvCurve).kr(Done.freeSelf, gate, timeScale);

	signal = FSinOsc.ar(bentFreq, initPhase, 0.75);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\sin, (
	instrument: \cleanS_sine,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\bendCurve].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\timeScale].defaultValue } },
	initPhase: { ~iph ?? { SynthDescLib.global.at(\cleanS_sine).controlDict[\initPhase].defaultValue } }
));
);




// Morphing sawtooth-triangle oscillator synth.
// Call it by providing \saw as a value to the \snd key in a pattern.
// Parameters:
// wid | iph
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq | out
// // (NEW: gate (and tsc on ampEnv))
// *tsc formerly named sustain
(
SynthDef(\cleanS_sawTri, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
	bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
	attack = \attack.ir(0.001).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(-8), gate = \gate.tr(1),
	timeScale = \timeScale.kr(1).abs;
	var initPhase = \initPhase.ir.clip(0, 1), width = \width.kr.clip(0, 1);

	var bendEnv, bentFreq, ampEnv, signal;

	bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	bentFreq = (freq * bendEnv).clip(20, 20000);

	ampEnv = Env.perc(attack, release, amp, ampEnvCurve).kr(Done.freeSelf, gate, timeScale);

	signal = VarSaw.ar(bentFreq, initPhase, width, 0.75);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\saw, (
	instrument: \cleanS_sawTri,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\bendCurve].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\timeScale].defaultValue } },
	initPhase: { ~iph ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\initPhase].defaultValue } },
	width: { ~wid ?? { SynthDescLib.global.at(\cleanS_sawTri).controlDict[\width].defaultValue } }
));
);




// Variable-duty pulse wave synth.
// Call it by providing \sqr as a value to the \snd key in a pattern.
// Parameters:
// wid | iph*
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq | out
// // (NEW: gate (and timeScale on ampEnv))
// *iph not implemented with Pulse
// *tsc formerly named sustain
(
SynthDef(\cleanS_pulse, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
	bendTime = \bendTime.ir(0.2), bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
	attack = \attack.ir(0.001).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(-8), gate = \gate.tr(1),
	timeScale = \timeScale.kr(1).abs;
	var initPhase = \initPhase.ir.clip(0, 1), width = \width.kr(0.25).clip(0, 1);

	var bendEnv, bentFreq, ampEnv, signal;

	bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	bentFreq = (freq * bendEnv).clip(20, 20000);

	ampEnv = Env.perc(attack, release, amp, ampEnvCurve).kr(Done.freeSelf, gate, timeScale);

	signal = Pulse.ar(bentFreq, width, 0.75); // LFPulse to have iph parameter
	// signal = LFPulse.ar(bentFreq, initPhase, width, 0.75);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\sqr, (
	instrument: \cleanS_pulse,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\bendCurve].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\timeScale].defaultValue } },
	initPhase: { ~iph ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\initPhase].defaultValue } },
	width: { ~wid ?? { SynthDescLib.global.at(\cleanS_pulse).controlDict[\width].defaultValue } }
));
);




// Karplus-Strong physical modeling of a vibrating string, using two delay lines (CombC & CombL) excited by an intial pulse (Impulse).
// Call it by providing \kps as a value to the \snd key in a pattern.
// Parameters:
// det (not currently implemented)
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq | out
// // (NEW: amp, atk, rel, crv, gate)
// *tsc formerly named sustain
(
SynthDef(\cleanS_karplusStrong, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
	bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
	attack = \attack.ir(0.002).abs, release = \release.ir(0.5).abs, ampEnvCurve = \ampEnvCurve.ir(-8), gate = \gate.tr(1),
	timeScale = \timeScale.kr(1).abs;
	var detune = \detune.kr(0.5);

	var bendEnv = Array.newClear(2), bentFreq = Array.newClear(2), ampEnv, signal;

	bendEnv[0] = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	bentFreq[0] = (freq * bendEnv[0]).clip(20, 20000);
	bentFreq[1] = freq.clip(20, 20000);
	// bendEnv[1] = Line.kr(1, 1 + detune.linlin(0, 1, -1, 1), timeScale); // for potential bend of second delay line (det==0.5: no bend)
	// bentFreq[1] = (freq * bendEnv[1]).clip(20, 20000);

	ampEnv = Env.linen(attack, timeScale - 0.004, release, amp, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/);

	signal = Decay.ar(Impulse.ar(0, 0, 0.1), 0.1 * freq.cpsmidi * 69.reciprocal) * WhiteNoise.ar;
	// hard panned delay lines (and added detune formulas) -
	// signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	// signal = [CombC.ar(signal, 0.05, bentFreq[0].reciprocal * (1 - (detune * 0.001)), timeScale),
	// CombL.ar(signal, 0.05, bentFreq[1].reciprocal * (1 + (detune * 0.001)), timeScale)];
	signal = CombC.ar(signal, 0.05, bentFreq[0].reciprocal, timeScale) + CombL.ar(signal, 0.05, bentFreq[1].reciprocal, timeScale);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\kps, (
	instrument: \cleanS_karplusStrong,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\bendCurve].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\timeScale].defaultValue } },
	detune: { ~det ?? { SynthDescLib.global.at(\cleanS_karplusStrong).controlDict[\detune].defaultValue } }
));
);




// Drum synth. This builds on the work of Rumble-San. http://blog.rumblesan.com/post/53271713518/drum-sounds-in-supercollider-part-1
// Call it by providing \drm as a value to the \snd key in a pattern.
// Parameters:
// tun | fed | pew | fco
// amp | pan | atk | rel | crv | gate | tsc* | out
// // (NEW: fco, amp, atk, rel, crv, gate)
// *tsc formerly named sustain
(
SynthDef(\cleanS_drum, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, attack = \attack.ir(0.01).abs, release = \release.ir(1).abs,
	ampEnvCurve = \ampEnvCurve.ir(-3), gate = \gate.tr(1), timeScale = \timeScale.kr(1).abs;
	var tune = \tune.kr.abs, feedback = \feedback.kr.abs, sweep = \sweep.kr(1).abs, cutoff = \cutoff.kr(9000).abs;

	var bendEnv, tuning, ampEnv, signal;

	tune = ((tune > 0) * tune) + ((tune < 1) * 3);
	tuning = (tune * 10).midicps;
	bendEnv = XLine.kr(tuning.expexp(10, 2000, 1000, 8000), tuning, 0.025 * sweep.reciprocal);

	ampEnv = Env.linen(attack, (timeScale - 1).max(0), release, amp, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/); // orig w/ sustainTime control

	signal = SinOscFB.ar(bendEnv, feedback);
	signal = LPF.ar(signal, cutoff);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\drm, (
	instrument: \cleanS_drum,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\pan].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\timeScale].defaultValue } },
	tune: { ~tun ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\tune].defaultValue } },
	feedback: { ~fed ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\feedback].defaultValue } },
	sweep: { ~pew ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\sweep].defaultValue } },
	cutoff: { ~fco ?? { SynthDescLib.global.at(\cleanS_drum).controlDict[\cutoff].defaultValue } },
));
);




// Hi-hat synth. This builds on the work of Rumble-San. http://blog.rumblesan.com/post/53271713518/drum-sounds-in-supercollider-part-1
// Call it by providing \hat as a value to the \snd key in a pattern.
// Parameters:
// tun | bnd | cfr
// amp | pan | atk | rel | crv | gate | tsc* | bnt | bno | bnc | out
// // (NEW: cfr, bnt, bno, bnc, amp, atk, rel, crv, gate)
// *tsc formerly named sustain
(
SynthDef(\cleanS_hat, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, bend = \bend.kr.clip(-1, 1), bendTime = \bendTime.ir(0.2).abs,
	bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir, attack = \attack.ir(0.01).abs,
	release = \release.ir(0.3).abs, ampEnvCurve = \ampEnvCurve.ir(-3), gate = \gate.tr(1), timeScale = \timeScale.kr(1).abs;
	var tune = \tune.kr.abs, centerFreq = \centerFreq.kr(2000).abs;

	var bendEnv, tuning, ampEnv, signal;

	bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	tuning = (tune.clip(-1.0, 1.0) * 5.reciprocal + 1).wrap(0.5, 2) * bendEnv * centerFreq;

	ampEnv = Env.linen(attack, (timeScale - 1).max(0), release, amp, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/);

	signal = HPF.ar(LPF.ar(WhiteNoise.ar(1), 3 * tuning), tuning);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\hat, (
	instrument: \cleanS_hat,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\pan].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\bendCurve].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\timeScale].defaultValue } },
	tune: { ~tun ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\tune].defaultValue } },
	centerFreq: { ~cfr ?? { SynthDescLib.global.at(\cleanS_hat).controlDict[\centerFreq].defaultValue } }
));
);




// Clap Synthesizer. This builds on the work of Nathan Ho: https://youtu.be/L9D78W8C-3w
// Call it by providing \clp as a value to the \snd key in a pattern.
// Parameters:
// srp | srq | bdy | bdt | tha | tho | fco | dmp
// amp | pan | atk | rel | crv | gate | tsc
// // (NEW: )
(
SynthDef(\cleanS_clap, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, attack = \attack.ir(0.05).abs, release = \release.ir(0.7).abs,
	ampEnvCurve = \ampEnvCurve.ir(-7), gate = \gate.tr(1), timeScale = \timeScale.kr(1).abs;
	var cutoff = \cutoff.kr(1611).abs, resonance = \resonance.kr(0.5).clip(0.01, 1), thumpAmp = \thumpAmp.kr(0.7).abs,
	thumpOffset = \thumpOffset.kr(0.7).abs, sharpness = \sharpness.kr(0.35).linlin(0.0, 1.0, -500, 500), damping = \damping.kr(11000).abs,
	bendTime = \bendTime.kr(0.2).abs, bendAmount = \bendAmount.kr(0.5).linlin(0.0, 1.0, 0.5, 1.0, nil);

	var signal, thump, filterFreq, pitchEnv, clapEnv, thumpEnv, ampEnv;

	filterFreq = cutoff + sharpness;
	pitchEnv = Env([1, 1 + bendAmount, 1], bendTime * 0.5, \exp).kr(0, gate);
	clapEnv = Env([0, 1, 0, 0.8, 0, 0.7, 0], [0.001, 0.008, 0.001, 0.008, 0.001, release]).kr(0, gate);
	thumpEnv = Env.perc(0.001, 0.1, 1, 2).kr(0, gate);

	ampEnv = Env.perc(attack, release, 1, -7).kr(Done.freeSelf, gate, timeScale);

	signal = Hasher.ar(Sweep.ar);
	thump = RHPF.ar(signal, filterFreq * thumpOffset * pitchEnv, 0.2) * thumpAmp * thumpEnv * 2;
	signal = BPF.ar(signal, filterFreq, resonance);
	signal = (signal * 30 * pitchEnv * 8).tanh;

	signal = (signal + thump).softclip;
	signal = signal.softclip * 1.4;
	signal = LPF.ar(signal, damping);

	signal = signal * clapEnv * ampEnv * (amp * 2);
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	ReplaceOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\clp, (
	instrument: \cleanS_clap,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\pan].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\timeScale].defaultValue } },
	sharpness: { ~srp ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\sharpness].defaultValue } },
	resonance: { ~srq ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\resonance].defaultValue } },
	damping: { ~dmp ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\damping].defaultValue } },
	bendAmount: { ~bdy ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\bendAmount].defaultValue } },
	bendTime: { ~bdt ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\bendTime].defaultValue } },
	thumpAmp: { ~tha ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\thumpAmp].defaultValue } },
	thumpOffset: { ~tho ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\thumpOffset].defaultValue } },
	cutoff: { ~fco ?? { SynthDescLib.global.at(\cleanS_clap).controlDict[\cutoff].defaultValue } }
));
);




// Transient excited filter.
// Call it by providing \dfd as a value to the \snd key in a pattern.
// Parameters:
// den | res | typ | nsl | ing
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq | out
// // (NEW: ing, tsc, bnd, bnt, bno, bnc, gate)
// *tsc formerly named sustain
(
SynthDef(\cleanS_filterPing, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440), bend = \bend.kr.clip(-1, 1),
	bendTime = \bendTime.ir(0.2).abs,bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
	attack = \attack.ir(0.001).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(-8), gate = \gate.tr(1),
	timeScale = \timeScale.kr(1).abs, resonance = \resonance.kr(1).clip(0, 1.01), density = \density.kr.abs,
	filterType = \filterType.kr.clip(0, 1), noiseAmount = \noiseAmount.kr.abs, gain = \gain.kr(1).abs;

	var bendEnv, bentFreq, ampEnv, signal;

	bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	bentFreq = (freq * bendEnv).clip(20, 7139);

	ampEnv = Env.linen(attack, (timeScale - 1).max(0), release, amp * 300, ampEnvCurve).kr(Done.freeSelf, gate /*, timeScale */);
	// ampEnv = Env.perc(attack, release, amp * 300, ampEnvCurve).kr(Done.freeSelf, gate, timeScale); // orig, with gate & timeScale added

	signal = Dust2.ar(density.dup(~clean.numChannels), amp);
	signal = DFM1.ar(signal, bentFreq, resonance, gain, filterType, noiseAmount);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan); // stereo image is perserved, but still allows panning
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\dfd, (
	instrument: \cleanS_filterPing,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\bendCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\timeScale].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\ampEnvCurve].defaultValue } },
	resonance: { ~res ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\resonance].defaultValue } },
	density: { ~den ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\density].defaultValue } },
	filterType: { ~typ ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\filterType].defaultValue } },
	noiseAmount: { ~nsl ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\noiseAmount].defaultValue } },
	gain: { ~ing ?? { SynthDescLib.global.at(\cleanS_filterPing).controlDict[\gain].defaultValue } }
));
);




// Digital waveguide physical model of a bowed instrument.
// Call it by providing \dfd as a value to the \snd key in a pattern.
// Parameters:
// frc | pos | bvl | bpr* | ind | fls | imp | inh
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq | out
// // (NEW: bvl, bpr, ind, fls, imp, inh, (gate on env, no BWG), tsc, bnd, bnt, bno, bnc)
// *tsc formerly named sustain
(
SynthDef(\cleanS_waveguide, {
	var out = \out.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs, bend = \bend.kr.clip(-1, 1),
	bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs, bendCurve = \bendCurve.ir,
	attack = \attack.ir(0.001).abs, release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(-8), gate = \gate.tr(1),
	timeScale = \timeScale.kr(1).abs, bowForce = \bowForce.kr(1).abs, bowPosition = \bowPosition.kr(0.07).clip(0, 1),
	bowVelocity = \bowVelocity.kr(1).abs, bowRelease = \bowRelease.kr(0.1).abs, inverseDecay = \inverseDecay.kr(0.25).abs,
	freqLoss = \freqLoss.kr(31).abs, impedance = \impedance.kr(0.55).abs, inharmonicity = \inharmonicity.kr(2).abs;

	var bendEnv, bentFreq, ampEnv, signal;

	bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
	bentFreq = (freq * bendEnv).clip(20, 5000);

	ampEnv = Env.linen(attack, (timeScale - 1).max(0), release, amp * 0.666, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/); // for timeScale?
	// ampEnv = Env.perc(attack, release, amp * 0.666, ampEnvCurve).kr(Done.freeSelf, gate, timeScale); // orig, with gate & timeScale added

	signal = DWGBowed.ar(bentFreq, bowVelocity, bowForce, 1, bowPosition, bowRelease, inverseDecay, freqLoss, impedance, inharmonicity);
	signal = DWGSoundBoard.ar(signal);
	signal = BPF.ar(signal, 118) + signal;
	signal = BPF.ar(signal, 430) + signal;
	signal = BPF.ar(signal, 490) + signal;
	signal = LPF.ar(signal, 6000);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\bow, (
	instrument: \cleanS_waveguide,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\freq].defaultValue } },
	bend: { ~bnd ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\bend].defaultValue } },
	bendTime: { ~bnt ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\bendTime].defaultValue } },
	bendStartOffset: { ~bno ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\bendStartOffset].defaultValue } },
	bendCurve: { ~bnc ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\bendCurve].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\timeScale].defaultValue } },
	bowForce: { ~frc ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\bowForce].defaultValue } },
	bowPosition: { ~pos ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\bowPosition].defaultValue } },
	bowVelocity: { ~bvl ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\bowVelocity].defaultValue } },
	bowRelease: { ~bpr ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\bowRelease].defaultValue } },
	inverseDecay: { ~ind ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\inverseDecay].defaultValue } },
	freqLoss: { ~fls ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\freqLoss].defaultValue } },
	impedance: { ~imp ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\impedance].defaultValue } },
	inharmonicity: { ~inh ?? { SynthDescLib.global.at(\cleanS_waveguide).controlDict[\inharmonicity].defaultValue } }
));
);




// External audio inputs.* Variations available for 1 to 8 (sequential) channels.
// Call it by providing \ex along with the number of channels (ie: \ex1 or \ex2, up to \ex8) as a value to the \snd key in a pattern.
// Parameters:
// inb
// amp | pan | atk | rel | crv | gate | tsc* | out
// // (NEW: inb, amp, atk, rel, crv, gate, tsc)
// *2-channel version formerly named \in
// *tsc formerly named sustain
({
	var channelGroups = (0 .. 7);
	var variableChannelExternalInputs = { |numCh|
		var channelArray = channelGroups.pyramidg(1);
		{
			var out = \out.ir, input = \input.ir, amp = \amp.kr(0.3), pan = \pan.kr,  attack = \attack.ir(0.001).abs,
			release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(-3), gate = \gate.tr(1), timeScale = \timeScale.kr(1).abs;

			var ampEnv, signal;

			ampEnv = Env.linen(attack, (timeScale - 1).max(0), release, amp, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/);

			signal = SoundIn.ar(input + channelArray[numCh]);

			signal = signal * ampEnv;
			signal = CleanPan.ar(signal, ~clean.numChannels, pan);
			OffsetOut.ar(out, signal)
		}
	};

	channelGroups.do{ |numCh|
		var fullName = (\cleanR_externalIn ++ (numCh + 1)).asSymbol;
		var cleanName = (\ex ++ (numCh + 1)).asSymbol;
		SynthDef(fullName, variableChannelExternalInputs.(numCh)).store;

		~clean.soundLibrary.addSynth(cleanName, (
			instrument: fullName,
			// out: { ~out },
			// amp: { ~amp ?? { SynthDescLib.global.at(fullName).controlDict[\amp].defaultValue } },
			// pan: { ~pan ?? { SynthDescLib.global.at(fullName).controlDict[\pan].defaultValue } },
			attack: { ~atk ?? { SynthDescLib.global.at(fullName).controlDict[\attack].defaultValue } },
			release: { ~rel ?? { SynthDescLib.global.at(fullName).controlDict[\release].defaultValue } },
			ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(fullName).controlDict[\ampEnvCurve].defaultValue } },
			gate: { ~gate ?? { SynthDescLib.global.at(fullName).controlDict[\gate].defaultValue } },
			timeScale: { ~tsc ?? { SynthDescLib.global.at(fullName).controlDict[\timeScale].defaultValue } },
			input: { ~inb ?? { SynthDescLib.global.at(fullName).controlDict[\input].defaultValue } }
		));
	};
}.value // this function is here as a cheat to allow variables to be created for the actual function.
);




// Pitch shifted external audio inputs.* Variations available for 1 or 2 (sequential) channels.
// Call it by providing \es along with the number of channels (ie: \es1 or \es2, up to \es2) as a value to the \snd key in a pattern.
// Parameters:
// inb | win | det | iph | bgn | end | spd
// amp | pan | atk | rel | crv | gate | tsc* | bnd | bnt | bno | bnc | freq | out
// // (NEW: inb, bnt, bno, bnc, amp, atk, rel, crv, gate, (and tsc on ampEnv))
// *formerly named \inr
// *tsc formerly named sustain
({
	var channelGroups = (0 .. 1);
	var variableChannelExternalInputs = { |numCh|
		var channelArray = channelGroups.pyramidg(1);
		{
			var out = \out.ir, input = \input.ir, amp = \amp.kr(0.3), pan = \pan.kr, freq = \freq.kr(440).abs,
			bend = \bend.kr.clip(-1, 1), bendTime = \bendTime.ir(0.2).abs, bendStartOffset = \bendStartOffset.ir.abs,
			bendCurve = \bendCurve.ir, attack = \attack.ir(0.001).abs, release = \release.ir(1).abs,
			ampEnvCurve = \ampEnvCurve.ir(-3), gate = \gate.tr(1), timeScale = \timeScale.kr(1).abs, windowSize = \windowSize.ir(0.1).abs,
			pitchDispersion = \pitchDispersion.kr(0.02).abs, timeDispersion = \timeDispersion.kr(0.01).abs,
			start = \start.ir.abs, end = \end.ir(1).abs, speed = \speed.kr(1).abs;

			var bendEnv, rate, ampEnv, signal, phase;

			bendEnv = Env([1, 1, 1 + bend], [bendStartOffset, bendTime * timeScale], [0, 0, bendCurve]).kr(0, gate);
			rate = (start + 1).max(0.001) * (speed * bendEnv) * (freq * freq.reciprocal);
			phase = Line.kr(start, end, speed) * timeDispersion; // dur arg was formerly timeScale

			ampEnv = Env.linen(attack, (timeScale - 1).max(0), release, amp, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/);

			signal = SoundIn.ar(input + channelArray[numCh]);
			signal = PitchShift.ar(signal, windowSize, rate % 4, pitchDispersion, phase % windowSize);

			signal = signal * ampEnv;
			signal = CleanPan.ar(signal, ~clean.numChannels, pan);
			OffsetOut.ar(out, signal)
		}
	};

	channelGroups.do{ |numCh|
		var fullName = (\cleanR_extInPitchShift ++ (numCh + 1)).asSymbol;
		var cleanName = (\es ++ (numCh + 1)).asSymbol;
		SynthDef(fullName, variableChannelExternalInputs.(numCh)).store;

		~clean.soundLibrary.addSynth(cleanName, (
			instrument: fullName,
			// out: { ~out },
			// amp: { ~amp ?? { SynthDescLib.global.at(fullName).controlDict[\amp].defaultValue } },
			// pan: { ~pan ?? { SynthDescLib.global.at(fullName).controlDict[\pan].defaultValue } },
			// freq: { ~freq ?? { SynthDescLib.global.at(fullName).controlDict[\freq].defaultValue } },
			bend: { ~bnd ?? { SynthDescLib.global.at(fullName).controlDict[\bend].defaultValue } },
			bendTime: { ~bnt ?? { SynthDescLib.global.at(fullName).controlDict[\bendTime].defaultValue } },
			bendStartOffset: { ~bno ?? { SynthDescLib.global.at(fullName).controlDict[\bendStartOffset].defaultValue } },
			bendCurve: { ~bnc ?? { SynthDescLib.global.at(fullName).controlDict[\bendCurve].defaultValue } },
			attack: { ~atk ?? { SynthDescLib.global.at(fullName).controlDict[\attack].defaultValue } },
			release: { ~rel ?? { SynthDescLib.global.at(fullName).controlDict[\release].defaultValue } },
			ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(fullName).controlDict[\ampEnvCurve].defaultValue } },
			gate: { ~gate ?? { SynthDescLib.global.at(fullName).controlDict[\gate].defaultValue } },
			timeScale: { ~tsc ?? { SynthDescLib.global.at(fullName).controlDict[\timeScale].defaultValue } },
			input: { ~inb ?? { SynthDescLib.global.at(fullName).controlDict[\input].defaultValue } },
			windowSize: { ~win ?? { SynthDescLib.global.at(fullName).controlDict[\windowSize].defaultValue } },
			pitchDispersion: { ~det ?? { SynthDescLib.global.at(fullName).controlDict[\pitchDispersion].defaultValue } },
			timeDispersion: { ~iph ?? { SynthDescLib.global.at(fullName).controlDict[\timeDispersion].defaultValue } },
			start: { ~bgn ?? { SynthDescLib.global.at(fullName).controlDict[\start].defaultValue } },
			end: { ~end ?? { SynthDescLib.global.at(fullName).controlDict[\end].defaultValue } },
			speed: { ~spd ?? { SynthDescLib.global.at(fullName).controlDict[\speed].defaultValue } }
		));
	};
}.value
);




// Internal audio input that receives audio from a specified bus.*
// Call it by providing \rcv as a value to the \snd key in a pattern.
// Parameters:
// inb
// amp | pan | atk | rel | crv | gate | tsc* | out
// // (NEW: amp, gate, atk, rel, crv)
// *formerly named \from
// *tsc formerly named sustain
(
SynthDef(\cleanR_busReceiver, {
	var out = \out.ir, input = \input.ir, amp = \amp.kr(0.3), pan = \pan.kr,  attack = \attack.ir(0.001).abs,
	release = \release.ir(1).abs, ampEnvCurve = \ampEnvCurve.ir(-3), gate = \gate.tr(1), timeScale = \timeScale.kr(1).abs;

	var ampEnv, signal;

	ampEnv = Env.linen(attack, (timeScale - 1).max(0), release, amp, ampEnvCurve).kr(Done.freeSelf, gate/*, timeScale*/);

	signal = InFeedback.ar(input, ~clean.numChannels);

	signal = signal * ampEnv;
	signal = CleanPan.ar(signal, ~clean.numChannels, pan);
	OffsetOut.ar(out, signal)
}).store;

~clean.soundLibrary.addSynth(\rcv, (
	instrument: \cleanR_busReceiver,
	// out: { ~out },
	// amp: { ~amp ?? { SynthDescLib.global.at(\cleanR_busReceiver).controlDict[\amp].defaultValue } },
	// pan: { ~pan ?? { SynthDescLib.global.at(\cleanR_busReceiver).controlDict[\pan].defaultValue } },
	// freq: { ~freq ?? { SynthDescLib.global.at(\cleanR_busReceiver).controlDict[\freq].defaultValue } },
	attack: { ~atk ?? { SynthDescLib.global.at(\cleanR_busReceiver).controlDict[\attack].defaultValue } },
	release: { ~rel ?? { SynthDescLib.global.at(\cleanR_busReceiver).controlDict[\release].defaultValue } },
	ampEnvCurve: { ~crv ?? { SynthDescLib.global.at(\cleanR_busReceiver).controlDict[\ampEnvCurve].defaultValue } },
	gate: { ~gate ?? { SynthDescLib.global.at(\cleanR_busReceiver).controlDict[\gate].defaultValue } },
	timeScale: { ~tsc ?? { SynthDescLib.global.at(\cleanR_busReceiver).controlDict[\timeScale].defaultValue } },
	input: { ~clean.audioRoutingBusses.wrapAt(~inb ?? { 0 }).index }
));
);

)


