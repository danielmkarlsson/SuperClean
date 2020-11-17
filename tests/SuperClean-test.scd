/*

INIT SUPERCLEAN

*/

(
s.quit;
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 16;
~clean.free; // free old instance
s.waitForBoot {
	~clean = SuperClean(2, s);
	~clean.loadSoundFiles;
	s.sync; // wait until all soundfiles are really loaded
	~clean.start(57120, [0, 0]); // play two orbits
}
)



/*
In theory, it should now receive tidal messages ...
---------------------------------------------------
*/



OSCFunc.trace(true, true); // see if network messages are coming in from tidal
OSCFunc.trace(false); // stop tracing


/*

SOME CONTROL

*/


// access separate clean busses directly
(

~d1 = ~clean.orbits[0]; // one orbit
~d2 = ~clean.orbits[1]; // the other orbit

)

// stop temporarily
~clean.stop;

// start again
~clean.start([57120, 57121)); // listen on two different ports: you can add any number of ports here

// finally, after the tests, you can free everything again:
~clean.free;



/*
The rest can be done from tidal, but here are some tests that call the function directly from sclang.
-----------------------------------------------------------------------------------------------------
*/


/*

TEST spd/START/END

*/

(
Tdef(\x, {
	loop {
		~d1.((sound: '808cy:10', spd: 2.0.rand2, accelerate:2.5.rand2));
		(0.2 * [1, 2, 1/3]).choose.wait;
	}
}).play;
)

(
Tdef(\x, {
	loop {
		~d1.((sound: ~clean.buffers.keys.choose, spd: 2.0.rand2, accelerate:2.5.rand2));
		(0.2 * [1, 2, 1/3]).choose.wait;
	}
}).play;
)
Tdef(\x).stop;


~d1.((sound: '808cy:10', spd: 1));
~d1.((sound: '808cy:10', spd: -1));
~d1.((sound: '808cy:10', spd: 2, accelerate: -1));
~d1.((sound: '808cy:10', spd: -2, accelerate: 1));

~d1.((sound: '808cy:10', spd: 1, accelerate: -0.2));
~d1.((sound: '808cy:10', spd: 0.5, accelerate: -0.3));

~d1.((sound: 'sd:8', spd: 1));
~d1.((sound: '808cy:10', spd: 2));


// ~d1.value2((sound: '808cy:10', spd: 1]));



/*
TEST PANNING
*/


~d1.((sound: '808cy:10', pan:0));
~d1.((sound: '808cy:10', pan:1));
~d1.((sound: '808cy:10', pan:0.5));
~d1.((sound: 'uxay', pan:0));
~d1.((sound: 'uxay', pan:1));
~d1.((sound: 'uxay', pan:0.5));

/*

TEST EFFECTS

*/


~d1.((sound: '808cy:10', spd: 0.2, crush: 4));
~d1.((sound: '808cy:10', spd: 0.2, coarse: 8));


~d1.((sound: '808cy:10', spd: 0.2, crush: 4, coarse: 38));
~d1.((sound: '808cy:10', spd: 1, crush: 4));
~d1.((sound: '808cy:10', spd: 1, hcutoff: 1000, hresonance: 20));
~d1.((sound: '808cy:10', spd: 1, hcutoff: 3000, hresonance: 10));
~d1.((sound: '808cy:10', spd: 1, bandqf: 3000, bandq: 100));
~d1.((sound: '808cy:10', spd: 1, bandqf: 3000, bandq: 100, coarse: 13));
~d1.((sound: '808cy:10', spd: 1, bandqf: 3000, bandq: 100, crush: 1));
~d1.((sound: '808cy:10', spd: 1, hcutoff: 1000, hresonance: 20, coarse: 0.10));



// (
// Tdef(\x, {
// 	loop {
// 		~d1.((sound: 'sd:8', bgn: 0, end: 1, spd: 1, vowel: "aeiou".choose.asSymbol, resonance: 0.6, cutoff: 540, amp: 1));
// 		1.wait;
// 		//(0.3 * [1, 2, 1/3]).choose.wait;
// 	}
// }).play;
// )
//
// (
// Tdef(\x, {
// 	loop {
// 		~d1.((sound: 'sd:8', bgn: 0, end: 1.0.rand, spd: 2.5, vowel: "aeiou".choose.asSymbol, resonance: 0.5, cutoff: 202));
// 		0.1.wait;
// 	}
// }).play;
// )
//
// // tough test
// (
// Tdef(\x, {
// 	loop {
// 		~d1.((sound: 'sd:8', bgn: 0, end: 1.0.rand, spd: 12.5, vowel: "aeiou".choose.asSymbol, resonance: 1, cutoff: 202));
// 		0.02.wait;
// 	}
// }).play;
// )
//
// Tdef(\x).stop;

/*

GLOBAL EFFECTS

*/

// test delay:

~d1.((sound: '808cy:10', spd: 1, dlt: 0.8, dla: 1));
~d1.((sound: '808cy:10', spd: 1, dlt: 0.8, dla: 1, dlf: 0.4));
~d1.((sound: '808cy:10', spd: 1, dlt: 0.8, dla: 0));
~d1.((sound: '808cy:10', spd: 1, dlt: 0.2, dla: 1));

fork { (0, 0.1 ..1).do { |a| ~d1.((sound: '808cy:10', spd: 1, dlt: 0.33, dla: a)); 1.wait } };


/*

TEST CUTGROUPS

*/


// cutgroup tests

~d1.((sound: '808cy:10', spd: 0.02, cut: -8)); // really slow, to keep it on: see synth reading
~d1.((sound: '808cy:10', spd: 0.02, cut: -8)); // cut the old one: number stays the same
~d1.((sound: '808cy:10', spd: 0.02, cut: -8)); // ... again

// this should add another one, as the cuts are independent between ~d1 and ~d2
~d1.((sound:'808cy:10', spd: 0.02, cut: -8));
~d1.((sound:'808cy:10', spd: 0.02, cut: -8)); // cut the old one, add the new one, same synth count


//  With negative, only stop the same sample from playing in the same cutgroup
~d1.((sound: '808cy:9', spd: 0.02, cut: -8)); // a different sample, is added
~d1.((sound: '808cy:9', spd: 0.02, cut: -8)); // the same sample, frees

//  with positive integers, stop samples playing that are in the same cutgroup.
~d1.((sound: '808cy:10', spd: 0.02, cut: 8)); // should free all others

~d1.releaseTime = 0.3;



/*

TEST UNIT

*/


/*
s unit -
"r" makes unit of spd and bgn/end time in terms of
ratio (the default described above),

"c" in terms of cycles per second
(i.e. 1 to play back at a spd that makes the sample exactly fill one
cycle), and

"s" in terms of seconds

*/

// \r

(
Tdef(\x, {
	var name = '808cy:10';
	var cps = 2;
	20.do {
		~d1.((cps:cps, sound:name, unit: \r, bgn: 0, end: 1));
		cps = cps + 0.3;
		(1/cps).wait;
	}
}).play
)


// \c
(
Tdef(\x, {
	var name = '808cy:10';
	var cps = 2;
	20.do {
		~d1.((cps:cps, sound:name, unit: \c, bgn: 0, end: 1));
		cps = cps + 0.3;
		(1/cps).wait;
	}
}).play
)

// \s
(
Tdef(\x, {
	var name = '808cy:10';
	var cps = 0.2;
	loop {
		~d1.((cps:cps, sound:name, unit: \s, bgn: 0, end: 0.2));
		0.2.wait;
	}
}).play
)

Tdef(\x).stop;

/*

TEST LIVE CODING SYNTHS

*/




// this is a default synth def

~d1.((sound: 'imp', spd: 1, bgn: 0, end: 1));
~d1.((sound: 'imp', spd: 1, bgn: 0.5, end: 1));


~d1.((sound: 'imp', spd: 0.1, bgn: 0, end: 1, accelerate: 3));

~d1.((sound: 'imp', spd: 1, bgn: 0, end: 0.3.rand, delay: 1, delaytime: 3));
~d1.((sound: 'imp', spd: 1, bgn: 0, end: 0.3.rand, delay: 1, delaytime: 3));
~d1.((sound: 'imp', spd: 1, bgn: 0, end: 0.3.rand, delay: 1, delaytime: 3));


(
Tdef(\x, {
	loop {
		~d1.(
			(
				sound: 'imp',
				spd: rrand(0.1, 2.0),
				bgn:1.0.rand,
				end: 2.0.rand,
				accelerate:2.0.rand,
				hcutoff: 4000.0.rand,
				hresonance: 0.5.rand,
				delay: 1.0.rand,
				delaytime: 0.2
		));
		0.5.wait;
	}
}).play;
)

(
Tdef(\x, {
	loop {
		~d1.(
			(
				sound: 'inr',
				spd: rrand(0.5, 2.0),
				bgn:1.0.rand,
				end: 2.0.rand,
				//accelerate:2.0.rand,
				//hcutoff: 4000.0.rand,
				//hresonance: 0.5.rand,
				delay: 1.0.rand,
				//delaytime: 0.2
		));
		0.15.wait;
	}
}).play;
)


// rewrite this at runtime
(
SynthDef(\imp, { |spd = 1, bgn=0, end=1, pan, accelerate, amp = 1, offset|
	var env, sound, dur, rate, phase;
	dur = (end - bgn) / spd;
	env = EnvGen.ar(Env.linen(0, 0.2, 0.8, amp * 0.1, -4), timeScale:dur, doneAction:2);
	phase = Line.ar(bgn + 0.0001, end, dur);
	rate = (bgn + 1) * (spd + Sweep.kr(1, accelerate));
	sound = Saw.ar(rate.linexp(0, 1, 1/[1, 3, 7], [1, 2, 5]) * 200).sum;
	sound = RHPF.ar(sound, phase.linexp(bgn, end, 300, 9000));
	env = env * ~clean.gateCutGroup; // this synth can be freed by cutgroup mechanism
	~clean.panOut(sound, pan, env)
}).add;
)

Tdef(\x).stop;




/*

NETWORK TEST

*/

OSCFunc.trace(true, true); // see if network messages are coming in from tidal
OSCFunc.trace(false); // stop tracing


// network test
n = NetAddr("127.0.0.1", 57120);

// Should pan left and right?
n.sendMsg(\play, 1, '808cy:10',0,0,1,1,0);
n.sendMsg(\play, 1, '808cy:10',0,0,1,1,1);

// feeding back
n.sendMsg(\play, 1, '808cy:10',0,0,1,1,0.5,0,"o");

n.sendMsg(\play, 1, '808cy:10',0,0,1,1,0.5,0);


n.sendMsg(\play, 1, 'breaks125');

n.sendMsg(\play, 1, \imp);

(
n.sendBundle(1.2, [\play, 1, 'cy']);
n.sendBundle(1.2, [\play, 1, 'cy']);
)

