// Karplus-Strong physical modeling of a vibrating string, using a delay line (CombL) excited by an intial pulse (Impulse)
// There are two delay lines
// "bnd" is used for a pitch glide, and "sustain" changes the envelope timescale
(
	SynthDef(\kps, {|out, sustain=1, pan, bnd, freq, detune=0.0 |
		var env = EnvGen.ar(Env.linen(0.002, 0.996, 0.002, 1,-3), timeScale:sustain, doneAction:2);
		var sound = Decay.ar(Impulse.ar(0,0,0.1), 0.1*(freq.cpsmidi)/69) * WhiteNoise.ar;
		var pitch = freq * Line.kr(1, 1+bnd, sustain);
		sound = CombL.ar(sound, 0.05, pitch.reciprocal*(1-(detune/100)), sustain) // remove detune because safety resons
		+ CombL.ar(sound, 0.05, pitch.reciprocal*(1+(detune/100)), sustain);
		OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env)) // move pan up before the two delay lines are introduced, hard pan them
	}).add
);

//  drum synthesis
// "sustain" controls the overall timescale, "pew" the filter sweep speed,
// and "fdb" the sinewave feedback
(
	SynthDef(\drm, {|out, pew=1, sustain=1, pan, fdb=0, tun |
		var env, sound, freq;
		tun = ((tun>0)*tun) + ((tun<1)*3);
		freq = (tun*10).midicps;
		env = EnvGen.ar(Env.linen(0.01, 0, 1, 1, -3), timeScale:sustain, doneAction:2);
		sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/pew), fdb), 9000);
		OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env))
	}).add
);

// Hi-hat using Rumble-San's implementation as a starting point
// http://blog.rumblesan.com/post/53271713518/drum-sounds-in-supercollider-part-1
// using "num" in a weird way to provide some variation on the frequency
// "sustain" affects the overall envelope rate, "bnd" sweeps the filter
(
	SynthDef(\hat, {|out, sustain=1, pan, bnd, num |
		var env, sound, accel, freq;
		env = EnvGen.ar(Env.linen(0.01, 0, 0.3, 1, -3), timeScale:sustain, doneAction:2);
		accel = Line.kr(1, 1+bnd.clip(-1.0,1.0), 0.2*sustain);
		freq = 2000*accel*(num/5 + 1).wrap(0.5,2);
		sound = HPF.ar(LPF.ar(WhiteNoise.ar(1), 3*freq), freq);
		OffsetOut.ar(out, CleanPan.ar(sound, ~clean.numChannels, pan, env))
	}).add
);