# SuperClean
A framework comprising of some basic utilities for use _inside_ of SuperCollider itself.  
Not only can you play back all of your samples without needless hassle in an environment that can grow with you.
SuperClean now also contains an FM synth, whose four justly tuneable operators deliver unparalleled cleanliness, even at
extreme modulation indexes. SuperClean even includes a remarkably efficient additive synth which literally sounds out of this
world. SuperClean is, in short, a one-stop-shopping-experience for folks who want:

• An MPC,  
• a bunch of effects,   
• some synths, and,
• a flexible routing system 

for the low, low asking price of: _free_.
Also, on a personal note here, hey, this is what I use to make music with every day.
I really love making music and, for me, this makes it way funner.
Try it! What have you got to loose?

![Maureen "Ma Dukes" Yancey smiling with her son J Dilla's MPC 3000](Dilla-Smithsonian-mpc1.jpg)

## Installation

Download the .zip,  
unzip it,  
make sure it's called SuperClean (_not_ SuperClean-master),  
then drag it into your Extensions folder.

## Updating

Drag the updated SuperClean folder to Extensions folder, which replaces the old SuperClean folder and you are done.
Make sure this folder is called SuperClean, not SuperClean-master.  
If you went with the Quarks option from way back when that was a thing, then click below.
<details>  
<br>
I have found that in order to be able to update consistently across 
different operating systems I need to first uninstall by running this line in SuperCollider:  

`Quarks.uninstall("SuperClean");`

I then manually delete the old SuperClean folder, reinstall with the above dragging to the folder Extensions method, then recompile the class library.

If you have used the old quarks method in the past then take extra special care to delete that old quarks SuperClean folder as you 
are updating because otherwise you might run into some double trouble there with your new SuperClean folder in Extensions. 
</details>
	
## Origins and acknowledgements

Julian Rohrhuber built this thing initially, then I changed some things here and there. I had a lot of help from friends along the way. 
What you have here is essentially a shameless ripOff / fork of / homage to SuperDirt. A special shoutout to Marcus Pal who initially created the FM synth and the 
additive synth.  
`mir` builds on the work of [David Granström](https://davidgranstrom.com/), specifically [EZConv](https://github.com/davidgranstrom/EZConv) 
which is just amazing.

## Requirements

* SuperCollider v3.9 or above: https://supercollider.github.io/download
* Mos def you should get the entirely essential sc3-plugins: https://github.com/supercollider/sc3-plugins/

## Lean is good

I only included a tiny amount of samples inside the clean-samples folder. I also trimmed the fat a lil bit with regards to the
effects and synths that are included. That's the main thing. I did that because that's a lot of data to have to download if
you're sharing a very slow wifi connection with 20 other kids who are also trying to get sat up at the same time. Also fewer
dependencies means less things that can go sideways with the install procedure.

## Be free to be you

Here's a way to hot swap in samples as needed:

```text
~clean.loadSoundFiles("~/Downloads/rnb");
```

Get your own samples in there! That's what I think everyone should do. That way you'll make this thing your own, and in no
time you'll be making your own kind of weird music. This also means you don't have to wait around for a bunch of samples
to load in to ram all the time when you need to start over quickly because reasons.

## Safe is necessary

I asked Scott to make sure that the filters are only able to accept values in the range of human hearing, 20 to 20000 hz.
This way the filters won't blow up. Also there is a nifty limiter that saves our ears ~~if~~ when things get unexpectedly
loud. This limiter can also be leaned in to on purpose yielding all manner of hawt sound. Be sure to not miss out on the
fun of sending values greater than one to `amp`.

## Start yer engines!

If you don't have anything in your Startup.scd, then how about you put what I use in there:

```text
// make sure you have sc3 plugins installed first
(
//var serverOptions = Server.default.options;serverOptions.outDevice = "Soundflower (2ch)";serverOptions.inDevice = "Soundflower (2ch)";//force devices
//"killall scsynth".unixCmd; // you might enjoy this if you are on a unix system
s.options.numBuffers = 1024 * 64; // increase if you need to load more samples
s.options.numWireBufs = 128; // increase if you get "exception in GraphDef_Recv: exceeded number of interconnect buffers." message
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
// thisProcess.platform.recordingsDir = "/your/path/here/"; // choose where supercollider recordings end up

// scnvim
if (\SCNvim.asClass.notNil) {
	Server.default.doWhenBooted {
		\SCNvim.asClass.updateStatusLine(1, 9670);
	}
};

// A simple triangle wave synth in stereo with panning and a simple low pass filter
// This synthDef was written by Mads Kjeldgaard and requires the sc3 plugins
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
	// for example: ~clean.loadSoundFiles("~/Downloads/rnb");
	s.sync; // optionally: wait for samples to be read
	~clean.start([0,0,0]); // first 8 out looks like [0,2,4,6]
	SuperClean.default = ~clean; // make the clean key sequenceable inside of SUperCollider
	"[ SuperClean up + running ]".postln;
};
)
```

If you _do_ have something in your Startup.scd, then you get to pick and choose which parts of mine you want to add to yours.

If, and only if, you are in that latter category, then proly the only part you for sure want to add in your Startup.scd (or
evaluate every time you want to run some SuperClean) in order for the below code to work on your machine is:

`SuperClean.default = ~clean;`

which is what makes clean sequenceable from _within_ SuperCollider.

Here's a slightly more involved, yet still minimal version:

```text
(
s.waitForBoot {
    ~clean = SuperClean(2, s);
    ~clean.loadSoundFiles;
    s.sync;
    ~clean.start([0]);
    SuperClean.default = ~clean;
};
)
```

## Whatsit look like?

Here are some examples of using the Pattern paradigm within SuperCollider to control SuperClean. First there's an example of
sequencing samples I made with my Micro Modular. Halfway down is an example of using the `fmx` synth which ships with
SuperClean. Finally at the end there you'll find an example of working with `uio` which is the additive synth. That example
uses a `Pfunc` to generate not just one pitch but a whole _bunch_ of pitches at the same time. Now, I know that looks a little
different. It is bringing another paradigm, functions, into Patterns. In SuperCollider there are many ways of doing the same
thing. Different strokes for different folks is all. Additive is such a wildly different way of making sound that it warranted
a different approach to control. I would have prefered to stay within the Pattern paradigm as it has been my experience that
SuperCollider is so vast that the scope needs to be narrowed somewhat in order to be approachable.

```text
// An example using fmx which is the built in four operator FM synthesizer.
(
Pdef(0,
	Pseed(4,
		Pbind(*[
			type: \cln,
			snd: \fmx,
			rps: Pexprand(9,99),
			hr1: Pstutter(Pkey(\rps)-Pwhite(0,7),Pshuf((1..4),inf)),
			hr2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
			hr3: Pstutter(Pkey(\rps)-Pwhite(0,7),Pshuf((1..4),inf)),
			hr4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((1..4),inf)),
			fdb: Pexprand(0.0001,100.0),
			mi2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			mi3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			mi4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pshuf((0.0001..4.0),inf)),
			en1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pexprand(0.0001,0.555)),
			en2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pexprand(0.2,0.666)),
			en3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pexprand(0.3,0.777)),
			en4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pkey(\en3)*Pexprand(0.4,0.888)),
			cu1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			amp: Pexprand(0.25,0.75),
			dur: Pstutter(Pkey(\rps)+Pwhite(2,9),2/Pbrown(5,19,Pwhite(1,3),inf)),
			legato: Pkey(\dur)*Pexprand(16,64),
			freq: (Pstutter(Pexprand(4,32),10*Pexprand(1,5).round)
				*Pstutter(Pexprand(1,64),Pexprand(1,5)).round
				*Pstutter(Pkey(\rps),Pexprand(1,7).round)),
			cav: Pseg(Pexprand(0.25,1.0),Pexprand(8.0,64.0),\welch,inf),
			pan: Pbrown(0.0,1.0,Pstutter(Pwhite(1,3),Pwhite(0.01,0.1))).trace,
			atk: Pexprand(0.01,4.0),
			hld: Pkey(\dur)*2,
			rel: Pkey(\dur)*2,
			crv: 5,
			sustain: Pexprand(2.5,5.0),
		])
	)
).play(quant:1);
);

// An example of using the sampler, looks for samples in a folder called mmd.
(
Pdef(\0,
    Pseed(Pn(999,1),
    Psync(
        Pbind(*[
            type: \cln,
            snd: \mmd,
            num: Pwhite(0,23),
            dur: Pwrand([1/12,1/3],[9,1].normalizeSum,inf),
            rel: Pstutter(Pwhite(1,8),Pseq([1/16,1/17,1/18,1/19,1/20,1/21,1/22,1/8,2],inf))*Pexprand(0.1,10.0),
            amp: Pexprand(1.0,8.0),
            pan: Pstutter(Pwhite(0,28),Pwrand([Pwhite(0.0,0.333),Pwhite(0.666,1.0)],[1,1.5].normalizeSum,inf)),
            lpf: Pwrand([625,1250,2500,5000,10000,20000],(1..6).normalizeSum,inf),
            spd: Pwrand([1/64,1/32,1/16,1/8,1/4,1/2,1,2,4,8,16,32,64],[1,2,4,8,16,32,64,32,16,8,4,2,1].normalizeSum,inf),
            shp: Pwhite(0.0,0.999).trace,
            dla: 0.001,
            dlf: 0.94,
            dlt: 1/2 / Pstutter(Pwrand([1,2,3],[256,16,1].normalizeSum,inf),Pbrown(1,199,Prand((1..19),inf),inf)),
            rin: Pwrand([0,0.05],[9,1].normalizeSum,inf),
            rev: 0.97,
            dry: Pstutter(Pwhite(1,9),Pwrand([0.25,1],[3,1].normalizeSum,inf)),
            hpf: 40,
        ]),1,15,
    )
)
).play(quant:1);
);
```

## Refurbishers welcome

SuperClean will work well with lower spec computers. If you'd like to add  
and remove sample folders as you go, maybe because you have a slightly older  
computer that you found in the tech trash, then this is for you:

```
~clean.postSampleInfo; // check which samples are loaded into ram and get some stats on those
~clean.freeSoundFiles([\rnb]); // remove a sample folder called rnb
~clean.postSampleInfo; // now, the rnb samples should be gone.
```

## How does it work?
I guess you could say it's a hack of the event type. You turn on SuperClean, as you might turn on the power for your 
rack of of samplers, synths and effects like this

```
(
Pdef(0,
	Pbind(*[
		type: \cln, // This line turns SuperClean on.
		snd: \mmd, // This line plays the first sample in the mmd folder.
	])
).play
)
```
Find more examples of code I have written using this framework in this companion repository called 
[SuperClean-code](https://github.com/danielmkarlsson/SuperClean-code)

## Modify all of the things!!!11

Now I might not be the bestest gun slinger there is round these here parts, but I was able to get this thing corralled, albeit
awkwardly, so just goes to show, you can too! If you end using this and modifying it to better suit your needs I'd love to talk you
about maybe including those changes here. Please get in touch with me through [my site](https://danielmkarlsson.com/).

