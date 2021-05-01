```
/*

This may not be a complete list of parameter names.
The value range for the below parameters is 0.0 to 1.0 unless otherwise indicated

snd         Sample folder or synth name
num         Which sample in a folder, from zero up to the amount of files in that folder and then wraps back around
pan         Pans the sound
shp         Waveshaping amount
sac         Shaping amplitude compensation
slo         Waveshaping low
shi         Waveshaping high
sho         Waveshaping offset
lot         Waveshaping low threshold
hit         Waveshaping high threshold
dst         A crunchy distortion with a lot of high harmonics
tri         A triode-like distortion
amp         Make it louder! Can go above one to lean into the limiter
spd         Sample playback speed, default is 1.0, negative numbers play the sample backwards, slower playback rates closer to 0
atk         The attack time of the envelope, the envelope parameters are expressed in seconds, 1.0 here means a one second fade in time
hld         The hold time of the envelope
rel         The release time of the envelope
crv         Envelope curvature, swings both ways. That is to say it uses both positive and negative values, try values between -8 to 8
lpf         Low pass filter, value range is 20 to 20000
hpf         High pass filter, value range is 20 to 20000
bpf         Band pass filter, value range is 20 to 20000
lpq         Low pass filter resonance
hpq         High pass filter resonance
bpq         Band pass filter resonance
lhf         Low & high pass filter combo where 0.5 does nothing, 0.0 sets the lpf to 20hz and 1.0 sets the hpf to 20000
dla         Delay amplitude
dlf         Delay feedback, proly best to think of 0.94 as the max sane value
dlt         Delay time, value range is a very low float to 16.0
rin         Set the amplitude of the input to the reverb
rev         Reverb time (or room size, if we can imagine that)
dry         Decrease the amplitude of the reverb
bgn         Where in the file to begin playing back the file
end         Where in the file to end playing back the file
bnd         Change playback speed of samples while running, accepts positive and negative values
lop         How many times to loop the file, takes integers, works in consort with the envelope parameters
cut         Cut groups, cuts itself as well as other things in the same cut group. Rougher edges than leagato in terms of sound
aux         An auxiliary output, you can use these for different outputs or same output with different effects depending on your startup file
rma         Ringmodulation wet
rmf         Ringmodulation frequency
rdf         The frequency to glissando in from, which can be above or below rmf, range is 20 to 20000
rdt         The time in seconds it takes to glissando from the detune frequency
smr         spectral smear
scm         spectral scramble
enh         spectral enhance

dur         The duration between events, range is a float above zero to infity, zero is infinitely fast, so, you mos def never want to do that
midinote    0 to 127. 60 is default. Interestingly accepts floats which allows for microtonality
freq        When working with synths and we want to work with frequencies instead of midi note numbers as above, accepts integers 20 to 20000
scale       Choose scale, for example: Scale.harmonicMinor, add a tuning there like this: Scale.harmonicMinor.tuning_(Tuning.sept1)
degree      Negative infinity to infinity really but proly there will be seven degrees in scale
octave      Choose the octave. Range is zero infinity really but a reasonable range is more like 1 to 6. Accepts floats which is crazy/fun
ctranspose  Chromatic transpostion. All keys on piano. Range is something like integers between -63 and 64 but depends on everything else.
mtranspose  Modal transposition of degree within a scale. Works in combination with other keys like degree and scale.
harmonic    Multiplies the frequency determined by midinote, typically to an overtone. https://en.wikipedia.org/wiki/Overtone

stepsPerOctave has no documentation that I can find. Very little is know about this strange parameter other than that it's default is 12.
Try untoggling that key in this example:

(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \fmx,
		dur: 1/8,
		pan: Pwhite(0.0, 1.0),
		degree: Pseq((0 .. 7), inf),
		stepsPerOctave: Pwhite(1,12),
	])
).play
)

There are some notable exceptions in this list of keys that provide convenient
calculation of frequency when compared to the equivalent list in SuperCollider.
This is because these keys have been reconstructed inside the custom event type
that is SuperClean. There are some workarounds. You can use ctranspose as a dropin
replacement for root. If you add 60 to a midinote value you get the equivalent
to note. If you add a fraction like for example 0.5 at the end of a midinote
calculation you get the equivalent of detune.

legato      Like a variable soft cut dependent on dur where 1 is equal to dur. This is unlike cut in that it only affects itself
sustain     Adds sustain by changing the timescale of the envelope. Can turn a drum into a drone. Value range is a float above 0 to infinity

This last group of parameters aren't actually part of SuperClean,
but are very useful and because SuperClean is running inside SuperCollider,
we can use them.

In the \fmx synth definition the envelope segments are expressed in
percentages. e4 through to e1 tell you how far into the note value that the
envelope should have reached it’s maximum level after the attack time, after
which the release time begins immediately. So an e1 value of 0.01 will yield a
1% duration for the attack and a 99% duration for the release. c4 through to c1
denote the curvature of the envelope segments. hr is the harmonicity ratio of
the operator. mi means modulation index, which is the modulation amount by
which that oscillator will modulate the next. The last oscillator (e1) doesn’t
have a modulation index value because it isn’t modulating anything else. The
first oscillator modulates itself with the fb parameter. SuperCollider has an
uncanny knack for delivering such clean synthesis, owing to negligible round
off errors in the calculation of waveforms at the lowest level. This becomes
especially important for me where modulation indexes are concerned. Without
this level of detail, FM can otherwise easily become a very round about way for
me to make white noise.

freq
hr1
hr2
hr3
hr4
fdb
mi2
mi3
mi4
en1
en2
en3
en4
cu1
cu2
cu3
cu4

In the \drm synth definition you can change the tuning of the drum with tun.
Strange wrapping and nonlinear range. Start trying values around 1.  The fdb
parameter controls the amount of feedback inside the oscillator. Value range is
0 to a lot where 0 is a sine, the higher up you go the noisier. The pew
parameter controls teh space blaster to metal kickdrum morph. Lower values are
more space blaster like. Higher values sound tighter.

tun
fed
pew

The \hat synth definition is a noise source through a filter and an envelope.
You can use tun in a weird way to provide some variation on the frequency.
bnd sweeps the filter.

tun
bnd

The \kps synth definition Karplus-Strong physical modeling of a vibrating string,
using a delay line (CombL) excited by an intial pulse (Impulse)
freq or midinote controls the frequency. bnd is used for a pitch glide

freq
bnd

The \sin synth definition is a sine wave oscillator. It accepts freq and midinote
and parameters like those. It can also let you control the initial phase with the
iph parameter. This might not be very exciting since it is a sine wave and frequency
is either 100% phase cancelled out or not at all.

freq
iph

The \saw synth definition is a saw wave oscillator. It accepts freq and midinote
and parameters like those. It can also let you control the initial phase with the
iph parameter. This might  potentially be very cool because you can then partially
phase out another saw wave. You can also control the width of the saw wave with
the wid parameter.

freq
iph
wid

The \sqr synth definition is a square wave oscillator. Same thing as above for the
parameters.

freq
iph
wid

The \dfd synth definition is a transient excited filter, the filter itself is noisy and can selfoscillate
den: the density of transients.
res: the resonance of the filter. 1 is a tremendous sweetspot. Range is 0 to infinity, values above 1 will wreak havoc.
typ: the type of filter where 0 is low pass and 1 is high pass.
nsl: the noise level. Range is 0 to infinity.

freq
den
res
typ
nsl

The \bow synth definition is a digital wave guide physical model of a bowed instrument.
frc: Force.
pos: Position.
bpr: Bow pressure.

freq
frc
pos
bpr

// Here's an example using most of the parameters from above all together in one wild mess
(
Pdef(0,
    Pseed(10,
        Pbind(*[
            type: Prand([\cln, \r], inf),
            dur: 1/Prand([1, 2, 4,8], inf),
            snd: Pxrand([\fmx, \drm, \hat, \dfd, \sin, \saw, \sqr],inf),
            scale: Scale.harmonicMinor.tuning_(Tuning.sept1),
            pan: Pwhite(0.0, 1.0),
            shp: Pexprand(1, 2) - 1,
            sac: 0.999,
            slo: Pexprand(1, 2) - 1,
            shi: 1 - Pexprand(0.01, 1),
            sho: Pwhite(0.0, 1.0),
            lot: Pexprand(1 ,2)-1,
            hit: Pexprand(1, 2)-1,
            dst: Pexprand(1, 2)-1,
            tri: Pexprand(1, 2)-1,
            amp: Pexprand(1, 1.5)-1,
            atk: Pexprand(1, 2)-1,
            hld: Pexprand(1, 4),
            rel: Pexprand(1, 2)-1,
            crv: Pexprand(1, 9)-1,
            lpf: 20000 - Pexprand(2000, 20000),
            hpf: Pexprand(20, 200),
            bpf: Pwhite(20, 200),
            lpq: Pwhite(0.0, 1.0),
            bpq: Pexprand(1, 2) - 1,
            hpq: Pexprand(1, 2) - 1,
            lhf: Pwhite(0.0, 1.0),
            rps: Pexprand(1, 9),
            dla: Pstutter(Pkey(\rps), (1 - Pexprand(0.1, 1.0))),
            dlf: Pstutter(Pkey(\rps), (0.9 - Pexprand(0.00001, 0.9))),
            dlt: Pstutter(Pkey(\rps), Pwhite(1.0, 16.0).round(1/2)),
            dlt: 16.0,
            hr1: Pstutter(Pkey(\rps) - Pwhite(0, 7), Pshuf((1 .. 4), inf)),
            hr2: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pshuf((1 .. 4), inf)),
            hr3: Pstutter(Pkey(\rps) - Pwhite(0, 7), Pshuf((1 .. 4), inf)),
            hr4: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pshuf((1 .. 4), inf)),
            fdb: Pexprand(0.0001, 100.0),
            mi2: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
            mi3: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
            mi4: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pshuf((0.0001 .. 4.0), inf)),
            en1: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pexprand(0.0001, 0.555)),
            en2: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pkey(\en1) * Pexprand(0.2, 0.666)),
            en3: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pkey(\en1) * Pkey(\en2) / Pexprand(0.3, 0.777)),
            en4: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pkey(\en1) * Pkey(\en2) / Pkey(\en3) * Pexprand(0.4, 0.888)),
            cu1: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
            cu2: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
            cu3: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
            cu4: Pstutter(Pkey(\rps) + Pwhite(0, 7), Pwhite(0.25, 1.0)),
            ada: Pexprand(0.00000000000000000000000000000000000000000000001, 10.1),
            adr: Pkey(\dur) + (Pexprand(0.000001, 10.0)),
            wid: (Pexprand(0.01, 0.5)),
            iph: Pwhite(0.0, 1.0),
            rin: Pwhite(0.0, 1.0),
            rev: Pwhite(0.0, 1.0),
            dry: Pwhite(0.0, 1.0),
            bgn: Pexprand(1, 1.25) - 1,
            end: 1 - Pexprand(0.75, 1.0),
            bnd: Pwhite(-1.5, 1.5),
            lop: Pexprand(1, 5) - 1,
            aux: Pwhite(0, 1),
            rma: Pwhite(0.0, 1.0),
            rmf: Pwhite(20, 200),
            rdf: Pwhite(20, 200),
            rdt: Pexprand(1, 2) - 1,
            smr: Pwrand([0, 1], [32, 1].normalizeSum, inf),
            scm: Pwrand([0,1],[16,1].normalizeSum,inf),
            enh: Pwrand([0,1],[8,1].normalizeSum,inf),
            dark: Pwrand([0,0.5],[4,1].normalizeSum,inf),
            degree: Pstutter(Pkey(\rps),Pxrand((0..7),inf)),
            octave: Pstutter(Pkey(\rps),Pxrand((2..6),inf)),
            sustain: Pexprand(1,4).round(0.25),
            legato: Pexprand(1,4).round,
        ])
    )
).play(quant:1);

Pdef(1,
    Pseed(1,
        Pbind(*[
            type: Prand([\cln, \r], inf),
            dur: 1/Prand([1, 2, 4,8], inf),
            snd: \mmd,
            num: Pwhite(0, 12),
            legato: Pexprand(1,4).round,
            pan: Pwhite(0.0, 1.0),
            amp: Pexprand(1,3)-1,
            spd: Prand([1/4,1/2,1,2,4,-0.25,-0.5,-2,-4],inf),
            rel: Pexprand(1,4)-1,
            crv: Pexprand(0.01,4)-4,
            cut: Pwhite(0,1),
            aux: Pwhite(0,1),
        ])
    )
).play(quant:1);

Pdef(2,
    Pseed(2,
        Pbind(*[
            type: \cln,
            snd: \add,
            freq: Pn(Plazy {
                var lo = (1 .. 11).choose;
                var hi = (1 .. 11).choose;
                50 * (lo..hi);
            }),
            ada: Pexprand(0.00000000000000000000000000000000000000000000001,10.1),
            adr: Pkey(\dur)+(Pexprand(0.000001,10.0)),
            dur: Prand([16, 32], inf) / Pwrand([1, 2, 4, 8],[8, 4, 2, 1].normalizeSum, inf),
            amp: Pexprand(0.5,1.0),
			legato: 1,
        ])
    )
).play(quant:1);

Pdef(3,
    Pseed(63,
        Pbind(*[
            type: Pwrand([\cln, \r],[1,0].normalizeSum, inf),
            snd: \kps,
            \freq, Pn(Plazy {
                var lo = (1, 3 .. 11).wchoose((11, 9 .. 1));
                var hi = (1, 3 .. 11).choose;
                50 * Pseq((lo..hi), 1);
            }).trace,
            dur: 1/Pstutter(Pwhite(5,11),Pwhite(5,11)),
            sustain: Pstutter(Pwhite(16,32),Pexprand(1/32,1)),
            crv: 8,
            amp: Pexprand(0.5,1.5),
            lhf: Pseg([0.0,0.5,0.0],Pexprand(1,40),\lin,inf),
            stretch: Pseg(Pseq([1,Pexprand(1/4,16),1],inf),Pexprand(1,20),\lin,inf),
            legato: 4,
        ])
    )
).play(quant:1);
)
```
