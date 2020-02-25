# SuperClean
a shameless ripOff / fork of / homage to SuperDirt

`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

`Quarks.install("https://github.com/danielmkarlsson/dirt-samples.git");`

If you don't have anything in your Startup.scd file then put this in there:

```
(
"killall scsynth".unixCmd;
s.options.numBuffers = 1024 * 128; // increase if you need to load more samples
s.options.memSize = 8192 * 256; // increase if you get "alloc failed" messages
s.options.maxNodes = 1024 * 64; // increase if drop outs and the message "too many nodes"
s.options.sampleRate= 44100;
s.options.numOutputBusChannels = 2; // OUTPUT CHANNELS GO HERE
s.recSampleFormat = "int24";
s.recHeaderFormat="wav";
s.options.numInputBusChannels = 2; // set to hardware input channel size, if necessary
s.latency = 0.1;
// MIDIClient.init; // Untoggle when you want to do MIDI
// m = MIDIOut.new(0); // Maybe yours is different?
// m.latency = 0; // Faster is better so fastest is bestest right?

// scnvim
if (\SCNvim.asClass.notNil) {
	Server.default.doWhenBooted {
		\SCNvim.asClass.updateStatusLine(1, 9670);
	}
};

// A simple triangle wave synth in stereo with panning and a simple low pass filter
// You need to install sc3 plugins for this to work.
s.doWhenBooted{
	SynthDef.new(\default, {
		arg dur, attack=0.01, release=1.0,
		t_gate=1, out, freq=442, cutoff=5500,
		rq=1, pan=0.0, amp=0.5;

		var env = EnvGen.kr(Env.perc(attack, release), t_gate, timeScale: dur, doneAction: 2);
		var sig = DPW3Tri.ar(freq: freq, mul: env);
		sig = RLPF.ar(sig, cutoff.clip(20.0, 20000.0), rq.clip(0.0,1.0));
		sig = Pan2.ar(sig, pan);
		Out.ar(out, sig * amp);
	}).add;
};

s.waitForBoot {
	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
	s.sync; // optionally: wait for samples to be read
	~dirt.start(57120, [0,2,4,6,8,10,12,14,16]);   // start listening on port 57120, create two busses each sending audio to channel 0
	SuperDirt.default = ~dirt;

};
);
```

If you _do_ have something in your Startup.scd, then you get to pick and choose which parts of mine you want to add to yours.

If, and only if, you are in that latter category, then proly the only part you for sure wan't to add in your Startup.scd in 
order for the below code to work on your machine is `SuperDirt.default = ~dirt;` which is what makes dirt sequneceable from
_within_ SuperCollider.

```text
(
    Pdef(\0,
        Pseed(Pn(9159,1),
            Psync(
                Pbind(*[
                    type: \dirt,
                    s: \mmd,
                    n: Pwhite(0,23),
                    dur: Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
                    release: Pstutter(Pwhite(1,8),Pseq([1/(16..22),1/8,2],inf)),
                    gain: Pexprand(1.0,4.0),
                    pan: Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
                    cutoff: Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
                    speed: Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
                    shape: Pstutter(Pexprand(1,99),Pexprand(0.01,0.9),inf), 
                    delay: 0.01,
                    delayfeedback: 0.9,
                    delaytime: 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
                    room: Pwrand([0,0.05],[9,1].normalizeSum,inf),
                    size: 0.97,
                    dry: Pstutter(Pwhite(1,9),Pwrand([0,1],[2,1].normalizeSum,inf)),
                ]),1,16,
            )
        )
    ).play(quant:1);
)

(
    Pdef(\1,
        Pbind(*[
        type: \dirt,
        s: \mmd,
        reps: Pexprand(6,66),
        n: Pstutter(Pkey(\reps),Pwhite(0,12)),
        release: Pstutter(Pkey(\reps),Pexprand(0.1,1.1)),
        gain: Pstutter(Pkey(\reps),Pwhite(0.5,4.0)),
        speed: Pstutter(Pkey(\reps),Pexprand(1/2,512.0)),
        pan: Pstutter(Pkey(\reps),Pwhite(0.0,1.0)),
        dur: Pstutter(Pkey(\reps),Pwhite(0.001,0.1)),
        begin: Pstutter(Pkey(\reps),Pexprand(0.001,0.2)),
        end: Pstutter(Pkey(\reps),Pexprand(0.19,0.6)),
        loop: Pstutter(Pkey(\reps),Pwhite(1,20)),
        stretch: (Pstutter(Pkey(\reps),Pwhite(1,9))/6).trace,
        accelerate: Pstutter(Pkey(\reps),Pwhite(-8.0,8.0)),
        shape: Pstutter(Pkey(\reps),Pwhite(0.9,0.999999)),
        cut: Pwrand([0,1],[8,1].normalizeSum,inf),
        ])
    ).play(quant:1);
)

(
    Pdef(\2,
        Pseed(3782,
        Pbind(*[
            type: \dirt,
            s: \mmd,
            n: 9,
            dur: Pstutter(Pwhite(3,33),Pexprand(0.125,0.666)),
            attack: (Pkey(\dur)/3),
            hold: (Pkey(\dur)/3),
            release: (Pkey(\dur)/3),
            speed: (Pkey(\dur)*Pstutter(Pwhite(13,133),Pwhite(0.666,33.333))),
            delay: 1/512,
            delaytime: 1/1024 / Pstutter(Pexprand(1,13),Pkey(\dur)*Pwhite(0.0,2.0)),
            delayfeedback: 0.94,
            stretch: Pstutter(Pwhite(3,33),Pexprand(0.125,1.0)),
            bandf: Pexprand(20,20000),
            cutoff: Pstutter(Pwhite(3,33),Pwhite(20,20000)),
            pan: Pwhite(0,1),
            gain: 16,
            room: 1,
            size: 0,
            dry: 0.999,
            cut: 1,
        ])
    )
).play(quant:1);
)
```


## TODO

• ~~.clip value ranges for all filters~~  
• Fix aliases for parameter names  
• All Dirt to Clean  
• Add samples and change path _inside_   
• Add pmx synthdef  
• Include `Pxshuf`  
• Include `Bjorklund`  
