# SuperClean
A SuperCollider implementation of the SuperClean sampler for use _inside_ of SuperCollider itself.
Not only can you play back all of your samples without needless hassle in an environment that can grow with you.
SuperClean now also contains an FM synth, whose four justly tuneable operators deliver unparalleled cleanliness, even at
extreme modulation indexes. SuperClean even includes a remarkably efficient additive synth which literally sounds out of this
world. SuperClean is, in short, a one-stop-shopping-experience for folks who want:

• An MPC,  
• a bunch of effects, and.   
• a couple of synths. 

for the low, low asking price of: _free_.
Also, on a personal note here, hey, this is what I use to make music with every day.
I really like making music and, for me, this makes it way funner.
Try it! What have you got to loose?

![Maureen "Ma Dukes" Yancey smiling with her son J Dilla's MPC 3000](Dilla-Smithsonian-mpc1.jpg)

## Installation

Copy this line and evaluate it in SuperCollider:

`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

If you don't have git, then go ahead and get git, when you hopefully get asked to get git, as a consequence of running that
line. Git is good to have. It let's us have version control and install all kinds of neat stuff. If you are on a mac then
it won't be that huge whole Xcode thing, it'll just be something called Xcode Select which is quite small.

## Updating

I have found that in order to be able to update consistently across different operating systems I need to first uninstall:

`Quarks.uninstall("SuperClean");`

I then manually delete the old SuperClean folder, reinstall with the below line then recompile the class library:

`Quarks.install("https://github.com/danielmkarlsson/SuperClean.git");`

That's how I do it. I'd love to find a simpler solution so let me know if you have one.

## Origins and acknowledgements

Julian Rohrhuber and Alex McLean built this thing initially, then I changed a few little things here and there.
Scott Cazan then gave me some much needed assistance in my little remodeling efforts. What you have here is essentially a
shameless ripOff / fork of / homage to SuperDirt. Marcus Pal created the FM synth and the additive synth.

## Requirements

* SuperCollider v3.9 or above: https://supercollider.github.io/download
* Mos def you should get the entirely essential sc3-plugins: https://github.com/supercollider/sc3-plugins/
* git (no link here because this will get taken care of by your os asking you to allow it to install git)

## Lean is good

I only included a tiny amount of samples inside the clean-samples folder. I also trimmed the fat a lil bit with regards to the
effects and synths that are included. That's the main thing. I did that because that's a lot of data to have to download if
you're sharing a very slow wifi connection with 20 other kids who are also trying to get sat up at the same time. Also fewer
dependencies means less things that can go sideways with the install procedure.

## Be free to be you

Here's a way to hot swap in samples as needed:

```
~clean.loadSoundFiles("~/Downloads/rnb");
```

Get your own samples in there! That's what I think everyone should do. That way you'll make this thing your own, and in no
time you'll be making your own kind of weird music. This also means you don't have to wait around for a bunch of samples
to load in to ram all the time when you need to start over quickly because reasons.

## Safe is necessary

I asked Scott to make sure that the filters are only able to accept values in the range of human hearing, 20 to 20000 hz.
This way the filters won't blow up. Also there is a nifty limiter that saves our ears ~~if~~ when things get unexpectedly
loud. This limiter can also be leaned in to on purpose yielding all manner of hawt sound. Be sure to not miss out on the
fun of sending values greater than one to `gain`.

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

If, and only if, you are in that latter category, then proly the only part you for sure want to add in your Startup.scd (or
evaluate every time you want to run some SuperClean) in order for the below code to work on your machine is:

`SuperClean.default = ~clean;`

which is what makes clean sequenceable from _within_ SuperCollider.

Here's a slightly more involved, yet still minimal version:

````
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

// an example of using the sampler, looks for samples in a folder called mmd
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

// an example using fmx which is the built in four operator FM synthesizer
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
			amp: Pexprand(0.25,0.75),
			en1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pexprand(0.0001,0.555)),
			en2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pexprand(0.2,0.666)),
			en3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pexprand(0.3,0.777)),
			en4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pkey(\en1)*Pkey(\en2)/Pkey(\en3)*Pexprand(0.4,0.888)),
			cu1: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu2: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu3: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			cu4: Pstutter(Pkey(\rps)+Pwhite(0,7),Pwhite(0.25,1.0)),
			dur: Pstutter(Pkey(\rps)+Pwhite(2,9),2/Pbrown(5,19,Pwhite(1,3),inf)),
			legato: Pkey(\dur)*Pexprand(16,64),
			freq: (Pstutter(Pexprand(4,32),10*Pexprand(1,5).round)
				*Pstutter(Pexprand(1,64),Pexprand(1,5)).round
				*Pstutter(Pkey(\rps),Pexprand(1,7).round)),
			dark: Pseg(Pexprand(0.25,1.0),Pexprand(8.0,64.0),\welch,inf),
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

/ an example using add which is the built in additive synthesizer
(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \add,
		amp: Pseg(Pexprand(0.4,0.7),Pexprand(0.4,4.0),\exp, inf),
		freq: Pfunc{
			var x = 40 * (1..7).choose * rrand(1,250).geom(1,30/29);
			x.reject{|i| i > 20000 }
		},
		dur: Pstutter(Pexprand(5,11),Pexprand(1,3).round/Pexprand(5,15).round),
		ada: Pexprand(0.00000000000000000000000000000000000000000000001,10.1),
		adr: Pkey(\dur)+(Pexprand(0.000001,10.0)),
		hpf: Pseg(Pexprand(40,4000),Pexprand(0.001,10.0),\exp, inf),
		adc: Pexprand(-8.0,-0.0001),
		slw: Pexprand(0.00001,10.0),
		pan: Pseg(Pwhite(0.1,0.9),Pwhite(1.0,10.0),\exp,inf),
		legato: Pexprand(0.25,1.25),
		sustain: Pexprand(0.25,1.25),
		stretch: Pseg(Pexprand(0.75,1.25),Pexprand(0.5,8.0),\exp, inf),
	])
).play(quant: 1);
)

```

In the \fmx synth definition the envelope segments are expressed in
percentages. e4 through to e1 tell you how far into the note value that the
envelope should have reached its maximum level after the attack time, after
which the release time begins immediately. So an e1 value of 0.01 will yield a
1% duration for the attack and a 99% duration for the release. c4 through to c1
denote the curvature of the envelope segments. hr is the harmonicity ratio of
the operator. mi means modulation index, which is the modulation amount by
which that oscillator will modulate the next. The last oscillator (e1) doesn’t
have a modulation index value because it isn’t modulating anything else.
SuperCollider has an uncanny knack for delivering such clean synthesis, owing
to negligible round off errors in the calculation of waveforms at the lowest
level. This becomes especially important for me where modulation indexes are
concerned. Without this level of detail, FM can otherwise easily become a very
round about way for me to make white noise.

## Refurbishers welcome

SuperClean will work well with lower spec computers. If you'd like to add  
and remove sample folders as you go, maybe because you have a slightly older  
computer that you found in the tech trash, then this is for you:

```
~clean.postSampleInfo; // check which samples are loaded into ram
~clean.freeSoundFiles([\rnb]); // this presupposes that you first add a sample folder called rnb
~clean.postSampleInfo; // now, the rnb samples should be gone.
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
• ~~Add `crv` param to env~~  
• ~~Raise output volume~~  
• ~~Stereo sample playback~~  
• ~~Set audible default values for `fmx`, what are sensible defaults?~~  
• ~~Pan not working in `fmx`~~  
• ~~Pan not working in `uio`~~  

• Reevaluate cubic interpolation (want longer file playback)  
• ReDo rm with feedback  
• Sequence the order of effects  
• FadeTime T1 style  
• NRT render inside SuperClean  

• Include `Pxshuf`  
• Include `Pbjorklund`  

• Swap out the reverb (how to make it sound better while still at low cpu?)  
• Maybe add that tape effect  
• Maybe delete some effects  

</details>

## Modify all of the things!!!11

Now I might not be the bestest gunSlinger there is round these here parts, but I was able to get this thing corralled, albeit
awkwardly, so just goes to show, you can too!
