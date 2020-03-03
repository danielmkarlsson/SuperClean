# SuperClean
A shameless ripOff / fork of / homage to SuperDirt.

## Installation

`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

If you don't have anything in your Startup.scd, then how about you put what I use in there:

```
(
"killall scsynth".unixCmd;
s.options.numBuffers = 1024 * 64; // increase if you need to load more samples
s.options.memSize = 8192 * 256; // increase if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase if drop outs and the message "too many nodes"
s.options.sampleRate= 44100;
s.options.numOutputBusChannels = 2; // OUTPUT CHANNELS GO HERE
s.recSampleFormat = "int24";
s.recHeaderFormat="wav";
s.options.numInputBusChannels = 2; // set to hardware input channel size, if necessary
s.latency = 0.3;
// MIDIClient.init; // Untoggle this when you want to do MIDI
// m = MIDIOut.new(0); // Maybe yours is different?
// m.latency = 0; // Faster is better so fastest is bestest right?

// scnvim
if (\SCNvim.asClass.notNil) {
 Server.default.doWhenBooted {
  \SCNvim.asClass.updateStatusLine(1, 9670);
 }
};

// A simple triangle wave synth in stereo with panning and a simple low pass filter
// This synthDef was created by Mads Kjeldgaard and requires the sc3 plugins
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
 ~clean = SuperClean(2, s); // two output channels, increase if you want to pan across more channels
 ~clean.loadSoundFiles; // hot swap in samples from anywhere!
 // for example: ~clean.loadSoundFiles("~/Downloads/mmd*");
 s.sync; // optionally: wait for samples to be read
    ~clean.start(57120, [0]); // first 8 out looks like [0,2,4,6]
 SuperClean.default = ~clean; // make the clean key sequanceable inside of SUperCollider
};
)
```

If you _do_ have something in your Startup.scd, then you get to pick and choose which parts of mine you want to add to yours.

If, and only if, you are in that latter category, then proly the only part you for sure wan't to add in your Startup.scd in 
order for the below code to work on your machine is `SuperClean.default = ~clean;` which is what makes clean sequneceable from
_within_ SuperCollider.

```text
(
    Pdef(\1,
        Pseed(Pn(63,1),
            Psync(
                Pbind(
                    \type, \clean,
                    \s, \mmd,
                    \n, Pwhite(0,23),
                    \dur, Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
                    \release, Pstutter(Pwhite(1,8),Pseq([1/(16..22),1/8,2],inf)),
                    \gain, Pexprand(1.0,4.0),
                    \pan, Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
                    \cutoff, Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
                    \speed, Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
                    \shape, Pstutter(Pexprand(1,99),Pexprand(0.01,0.9),inf), 
                    \delay, 0.01,
                    \delayfeedback, 0.9,
                    \delaytime, 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
                    \room, Pwrand([0,0.05],[9,1].normalizeSum,inf),
                    \size, 0.97,
                    \dry, Pstutter(Pwhite(1,9),Pwrand([0,1],[2,1].normalizeSum,inf)),
                ),1,inf,
            )
        )
    ).play(quant:1);
);
```


## TODO  
(reOrdered to reflect relevance)  

• ~~Single line installation~~  
• ~~.clip value ranges for all filters~~  
• ~~All Clean to Clean~~  
• Fix aliases for parameter names  
• Add samples and change path _inside_ SuperClean  
• Pros/cons of env keys value range relating to sample length (like `begin` & `end`)  
• Investigate possible bug where long samples (try an hour) will play back at lower sample rate  
• Add FM synthdef  
• Add Additive synthdef    
• Include `Pxshuf`  
• Include `Pbjorklund`  
• Add or swap out some effects  
