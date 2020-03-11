# SuperClean
A SuperCollider implementation of the SuperClean sampler for use _inside_ of SuperCollider itself.  
Not only can you play back all of your samples without needless hassle in an environment that can grow with you.
SuperClean now also contains an FM synth whose four justly tuned operators deliver unparalleled clenaliness, even at extreme
modulation indexes. SuperClean even includes a remarkably efficient additive synth which literally sounds out of this world.
It is in short a one-stop-shopping-experience for folks who want: 

• An MPC,  
• A bunch of effects, and   
• A couple of synths   

for the low, low asking price of: _free_.

## Installation

Copy this line and evaluate it in SuperCollider:

`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

If you don't have git, then go ahead and get git, when you hopefully get asked to get git, as a consequence of running that
line. Git is good to have. It let's us have version control and install all kinds of neat stuff.

## Origins and acknowledgements

Alex McLean and Julian Rohrhuber built this thing initially, then I changed a few little things here and there.  
Scott Cazan then gave me some much needed assistance in my little remodeling efforts. What you have here is essentially a
shameless ripOff / fork of / homage to SuperDirt. Marcus Pal created the FM synth and the additive synth.

## Requirements

* SuperCollider v3.9 or above: https://supercollider.github.io/download
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
This way the filters wont blow up. Also there is a nifty compressor that saves our ears when things get unexpectedly loud.
This compressor can also bea leaned in to on purpose yielding all manner of hawt sound. Be sure to not miss out on the fun of
sending values greater than one to `gain`.

## Start yer engines!

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

which is what makes clean sequenceable from _within_ SuperCollider.

## Whatsit look like?

Here are some examples of using the Pattern paradigm within SuperCollider to control SuperClean. First there's an example of 
sequencing samples I made with my Micro Modular. Halfway down is an example of using the `fmx` synth which ships with 
SuperClean. Finally at the end there you'll find an example of working with `uio` which is the additive synth. That example
uses a `Pfunc` to generate not just one pitch but a whole _bunch_ of pitches at the same. Now, I know that looks a little 
different. It is bringing another paradigm, functions, into Patterns. In SuperCollider there are many ways of doing the same
thing. Different strokes for different folks is all. Additive is such a wildly different way of making sound that it warranted
a different approach to control. I would have prefered to stay within the Pattern paradigm as it has been my experience that 
SuperCollider is so vast that the scope needs to be narrowed somewhat in order to 

```text
// mmd example
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

// fmx example
(
Pdef(\0,
    Pseed(4,
    Pbind(*[
        type: \clean,
        s: \fmx,
        rps: Pwhite(1,99),
        hr1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pxshuf((1..4),inf)),
        hr2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pxshuf((1..4),inf)),
        hr3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pxshuf((1..4),inf)),
        hr4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pxshuf((1..4),inf)),
        mi2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pxshuf((1.0..4.0),inf)),
        mi3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pxshuf((1.0..4.0),inf)),
        mi4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pxshuf((1.0..4.0),inf)),
        fdb: Pexprand(0.01,100.0),
        amp: Pexprand(0.1,8.0),
        en1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pexprand(0.0001,1.1)),
        en2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pexprand(0.0001,2.1)),
        en3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pexprand(0.0001,3.1)),
        en4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pkey(\en3)*Pexprand(0.0001,4.1)),
        hl1: Pexprand(0025,1.125),
        hl2: Pexprand(0.025,1.125),
        hl3: Pexprand(0.025,1.125),
        hl4: Pexprand(0.025,1.125),
        cu1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.0,4.0)),
        cu2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.0,4.0)),
        cu3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.0,4.0)),
        cu4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.0,4.0)),
        dur: Pstutter(Pkey(\rps)+Pwhite(2,9),1.25/Pbrown(3,17,Pwhite(1,3),inf)),
        legato: Pexprand(7.5,90.0),
        freq: (Pstutter(Pwhite(8,16),Prand((10,20..40),inf))*Pwhite(1,5)*Pstutter(Pkey(\rps),Pwhite(1,5))).trace,
        hpf: Pexprand(20,20000),
        lpf: Pkey(\freq).linlin(10,1600,20000,100,\minmax),
        room: Pseg(Pexprand(0.9,1),Pexprand(2.0,8.0),\welch,inf),
        size: Pseg(Pexprand(0.9,1),Pexprand(4.0,16.0),\welch,inf),
        dry: Pseg(Pexprand(0.9,1),Pexprand(8.0,32.0),\welch,inf),
        //orbit: Pwhite(0,3), // untoggle if you have 8 outputs
    ]);
)
).play;
);

// uio example

(
    Pdef(\0, 
        Pseed(11,
        Pbind(*[
            type: \clean,
            s: \uio,
            tempo: 3,
            rps: Pexprand(1,149),
            rpf: Pstutter(Pkey(\rps),Pwhite(1,9999)),
            psi: Pstutter(Pkey(\rps),Psinen(0.1).linlin(0,1,0.25,1.0)),
            pwi: Pstutter(Pkey(\rps),20000/Pwhite(1,99)),
            freq: Pfunc{|envir|
                var psi = envir.psi;
                var pwi = envir.pwi;
                var rpf = envir.rpf;
                var x = pwi * rpf.geom(1,90/(89*psi).asInteger);
                //x.postln;
                x.reject{|i| i > 20000 }
            } * Pstutter(Pkey(\rps),Pwhite(0.9,1.1)),
            dur: 1/Pstutter(Pkey(\rps),Pwhite(2,11),inf)*Pstutter(Pkey(\rps),Pexprand(1.0,2.0)).trace,
            attack: Pstutter(Pkey(\rps),Pexprand(0.00001,0.01)),
            release: Pstutter(Pkey(\rps),Pexprand(0.01,20.0)),
            curve: -8,
            stereoDetune: Pstutter(Pkey(\rps),Pwhite(100.0,1000.0)),
            stretch: Pseg([Pwhite(1/2,2.0),Pwhite(1/2,2.0)],Pwhite(15,90),\lin,inf),
            gain: Pseg([Pwhite(2.0,8.0),Pwhite(2.0,8.0)],Pwhite(15,90),\welch,inf),
            hpf: Pseg([20,2000,20,20],Pwhite(15,90),\welch,inf),
            bpf: Pstutter(Pkey(\rps),Pexprand(20,10000)),
            bpq: Pstutter(Pkey(\rps),Pexprand(0.1,1.0)),
        ]))
    ).play;
)
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

• Set audible default values for fmx, what are sensible defaults?  
• Might there be a way to lessen the likeliness of the envelopes in fmx clicking?  
• Pan not working in fmx  
• Pan not working in uio  
• Pros/cons of env keys value range relating to sample length (like `begin` & `end`)  
• Investigate possible bug where long samples (try an hour) will play back at lower sample rate  
• `doneAction:2` , why not? Hopefully solves `loop` edge cases and longer releases never finishing

• Include `Pxshuf`  
• Include `Pbjorklund`  

• Swap out the reverb (how to make it sound better while still at low cpu?)  
• Maybe add that tape effect  
• Maybe delete some effects    

</details>

## Modify all of the things!!!11

Now I might not be the bestest gunSlinger there is round these here parts, but I was able to get this thing corralled, albeit
awkwardly, so just goes to show, you can too!

