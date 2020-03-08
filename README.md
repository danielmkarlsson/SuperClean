# SuperClean
A SuperCollider implementation of the Clean sampler for use _inside_ of SuperCollider itself.

Alex McLean and Julian Rohrhuber built this thing initially, then I changed a few little things here and there.  
I need everyone to know that Scott Cazan did the heavy lifting in my little remodeling efforts. What you have here is 
essentially a shameless ripOff / fork of / homage to SuperDirt.
Marcus Pal created the FM synth and the Additive synth.

## Requirements

* SuperCollider v3.7 or above: https://supercollider.github.io/download
* Mos def you should get the entirely essential sc3-plugins: https://github.com/supercollider/sc3-plugins/
* git (no link here because this will get taken care of below)

## Lean is good

I only included a tiny amount of samples inside the clean-samples folder. I also trimmed the fat a lil bit with regards to the 
effects and synths that are included. That's the main thing. I did that because that's a lot of data to have to download if 
you're sharing a very slow wifi connection with 20 other kids who are also trying to get sat up at the same time. Also fewer 
dependencies means less things that can go sideways with the install procedure.

## Be free to be you

There's a way to hot swap in samples as needed:

```
~clean.loadSoundFiles("~/Downloads/mmd*");
```

Get your own samples in there! That's what I think everyone should do. That way you'll make this thing your own, and in no 
time you'll be making your own kind of weird music. This also means you don't have to wait around for a bunch of samples
to load in to ram all the time when you need to start over quickly because reasons.

## Safe is necessary
 
I asked Scott to make sure that the filters are only able to accept values in the range of human hearing, 20 to 20000 hz. 
This way the filters wont blow up.

## Installation

Copy this line and evaluate it in SuperCollider:

`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

If you don't have git, then go ahead and get git, when you hopefully get asked to get git, as a consequence of running that
line. Git is good to have. It let's us have version control and install all kinds of neat stuff.

<br><br>

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

If, and only if, you are in that latter category, then proly the only part you for sure wan't to add in your Startup.scd (or
evaluate every time you want to run some SuperClean) in order for the below code to work on your machine is:

`SuperClean.default = ~clean;` 

which is what makes clean sequneceable from _within_ SuperCollider.

```text
(
    Pdef(\0,
        Pseed(Pn(999,1),
            Psync(
                Pbind(*[
                    type: \clean,
                    s: \mmd,
                    n: Pwhite(0,23),
                    dur: Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
                    rel: Pstutter(Pwhite(1,8),Pseq([1/16,1/17,1/18,1/19,1/20,1/21,1/22,1/8,2],inf))*Pexprand(0.1,10.0),
                    gain: Pexprand(1.0,8.0),
                    pan: Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
                    lpf: Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
                    speed: Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
                    shp: Pwhite(0.0,0.999).trace,
                    dla: 0.001,
                    dlf: 0.94,
                    dlt: 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
                    room: Pwrand([0,0.05],[9,1].normalizeSum,inf),
                    size: 0.97,
                    dry: Pstutter(Pwhite(1,9),Pwrand([0.25,1],[3,1].normalizeSum,inf)),
                    hpf: 40,
                ]),1,15,
            )
        )
    ).play(quant:1);
);
```


## TODO  
<details>
<summary>(reOrdered to reflect relevance)</summary>

• ~~Single line installation~~  
• ~~.clip value ranges for all filters~~  
• ~~All Clean to Clean~~  
• ~~Add samples and change path _inside_ SuperClean~~  
• ~~Fix aliases in core-synths.scd (bpf stuck at default value)~~  
• ~~Fix aliases in core-synths-global.scd, seems to inherit keys from Synthdef args, dla,dlf,dlt is goal~~   
• ~~Add FM synthdef~~  
• ~~Add Additive synthdef~~ 

• Pros/cons of env keys value range relating to sample length (like `begin` & `end`)  
• Investigate possible bug where long samples (try an hour) will play back at lower sample rate  
• `doneAction:2` , why not? Hopefully solves `loop` edge cases and longer releases never finishing

• Include `Pxshuf`  
• Include `Pbjorklund`  

• Swap out the reverb (how to make it sound better while still low cpu?)
• Maybe add that tape effect  
• Maybe delete some effects    

</details>

## Modify all of the things!!!11

Now I might not be the bestest gunSlinger there is round these here parts, but I was able to get this thing corralled, albeit
awkwardly, so just goes to show, you can too!

