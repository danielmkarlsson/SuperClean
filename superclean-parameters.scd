This may not be a complete list of parameter names.
The value range for the below parameters is 0.0 to 1.0 unless otherwise indicated.

>>> EVENT based effect parameters (added individually per sound) <<<

snd:	Sample folder or synth name.
num:	Which sample in a folder, from zero up to the amount of files in that folder and then wraps back around.
pan:	Pans the sound. Value range is 0.0, 1.0 where 0.0 is all the way left and 1.0 is all the way right.
shp:	Waveshaping amount. Value range is 0.0, 1.0 where 0.0 is all the way dry and 1.0 is all the way wet.
sac:	Waveshaping amplitude compensation. Value range is 0.0, 1.0
slo:	Waveshaping low. Value range is 0.0, 1.0
shi:	Waveshaping high. Value range is 0.0, 1.0
sho:	Waveshaping offset. Value range is 0.0, 1.0
lot:	Waveshaping low threshold. Value range is 0.0, 1.0
hit:	Waveshaping high threshold. Value range is 0.0, 1.0
dst:	A crunchy distortion with a lot of high harmonics. Value range is 0.0, 1.0
tri:	A triode-like distortion. Value range is 0.0, 1.0
amp:	Make it louder! Can go above one to lean into the limiter. Value range is 0.0 to infinity.
spd:	Sample playback speed, default is 1.0, negative numbers play the sample backwards, slower playback rates closer to 0
atk:	The attack time of the envelope, these three envelope parameters are expressed in seconds, 1.0 here means a one second fade in time.
hld:	The hold time of the amplitude envelope.
rel:	The release time of the amplitude envelope.
crv:	Attack curvature, swings both ways. That is to say it uses both positive and negative values, try values between -8 to 8
crt:	Release curvature, swings both ways. That is to say it uses both positive and negative values, try values between -8 to 8
lpf:	Low pass filter, value range is 20 to 20000
hpf:	High pass filter, value range is 20 to 20000
bpf:	Band pass filter, value range is 20 to 20000
lpq:	Low pass filter resonance. Value range is 0.0, 1.0 where 0.0 is no resonance and 1.0 is all the way resonant.
hpq:	High pass filter resonance. Value range is 0.0, 1.0 where 0.0 is no resonance and 1.0 is all the way resonant.
bpq:	Band pass filter resonance. Value range is 0.0, 1.0 where 0.0 is no resonance and 1.0 is all the way resonant.
lhf:	Low & high pass filter combo where 0.5 does nothing, 0.0 sets the lpf to 20hz and 1.0 sets the hpf to 20000
hlf:	High & low pass filter combo, catches typos and nice to have two, the order of the filters are reversed, not that it matters.
brf:	Band reject filter, value range is 20 to 20000
brq:	Band reject filter resonance. Value range is 0.0, 1.0 where 0.0 is no resonance and 1.0 is all the way resonant.
brn:	Number of Band reject filters. Value range is 0.0, 1.0 where 0.0 is one filter 1.0 is ten filters.
bro:	Band reject filter offset. Offset up to 1/3 octave per filter.
dla:	Delay amplitude. Value range is 0.0 to infinity.
dlf:	Delay feedback, proly good to think of 0.94 as the max sane value, although the value range is actually 0.0 to 1.0
dlt:	Delay time, value range is a very low float to 128.0
rin:	Reverb input gain. Value range is 0.0, 1.0
rev:	Reverb time (or room size, if we can imagine that). Value range is 0.0, 1.0
dry:	Decrease the amplitude of the reverb. Value range is 0.0, 1.0
bgn:	Where in the file to begin playing back of the file. Value range is 0.0, 1.0 where 0.0 is the beginning and 1.0 is the end
end:	Where in the file to end playing back the file.Value range is 0.0, 1.0 where 0.0 is the beginning and 1.0 is the end
bnd:	Bend. Change playback speed of samples while running, accepts positive and negative values. Certain synths also accept bnd.
bnt:	Bend time. Accepts positive values. This value gets multiplied with the sustain key. The default is 0.2 seconds
bno:	Offset the time at which the bend begins. Value range is 0.0 to infinity
bnc:	Bend curvature. Accepts positive and negative values.
cut:	Cut groups, cuts itself as well as other things in the same cut group. Rougher edges than legato in terms of sound tho so.
aux:	Auxiliary output, can be used for different outputs or same output with different effects depending on your startup file.
rma:	Ringmodulation wet amount. Value range is 0.0, 1.0
rmf:	Ringmodulation frequency. Value range is a very low float to 20000 where values closer to zero yield very nice AM instead.
rdf:	The ringmodulation frequency to glissando in from, which can be above or below rmf. Value range is a very low float to 20000
rdt:	The time in seconds it takes to glissando from the ringmodulation detune frequency.
smr:	Spectral smear. Value range is 0.0, 1.0
scm:	Spectral scramble. Value range is 0.0, 1.0
enh:	Spectral enhance. Value range is 0.0, 1.0
ocu:	Octave up. Value range is 0.0, 1.0
ocd:	Octave down. Value range is 0.0, 1.0
ocq:	Quarter-frequency harmonics (two octaves down). Value range is 0.0, 1.0
fsh:	Frequency shift, value range goes both positive and negative, works in combination with fsm, try values -32.0 to 32.0
fsm:	Frequency shift multiplier, value range goes both positive and negative, works in combination with fsh, try values -4.0 to 4.0
fuz:	A very raw kind of distortion. Has a built in gate. Very touch sensitive. Value range is 0 or 1. On or off.
fzv:	Fuzz value. Value range is zero to infinity.
bit:	Roughly translates to bit rate reduction. Value range is zero to infinity. Lower values give more action.
sam:	Roughly translates to sample rate reduction. Value range is zero to infinity. Higher values give more action.
flp:	Flips the channels in a Stereo file. Value range is 0 or 1, where 0 is unaffected and 1 is flipped.
psd:    Phase decorellator depth. Value range is 0.0, 1.0
psa:    Phase decorellator accumulution. Value range is 0.0, 1.0
psi:    Phase decorellator input gain. Value range is 0.0, 1.0
pso:    Phase decorellator output gain. Value range is 0.0, 1.0
psb:    Phase decorellator blend. Value range is 0.0, 1.0

>>> GLOBAL effect parameters (added to the sum of all sounds in an aux) <<<

mir:	An Impulse Response based reverb, this is the wet parameter, or the amplitude of the reverb. Range is zero to infinity
mii:	The input or send into the mir reverb. Value range is 0.0, 1.0
hal:	The hall reverb output amplitude
hai:	The input or send into the hal reverb. Value range is 0.0, 1.0
rts:	The RT60 value of the reverb. This goes from 0 to 999. That top value is approaching inifity. It is super duper long.
edf:	Early diffusion of the hal reverb. Value range is 0.0, 1.0
ldf:	Late diffusion of the hal reverb. Value range is 0.0, 1.0
hhp:	A high pass filter before the hal reverb. Value range is 20 to 20000.
hlp:	A low pass filter before the hal reverb. Value range is 20 to 20000.
tnh:	Wet mix of tanh based distortion. Unlike other distortions this is added after synths are summed. Try a fifth through this.
tnb:	Low pass filter before the tanh based distortion. Value range is 0.0, 1.0
tng:	Tanh gain stage, this makes tons of ditortion. Range is 0.0 to 999.0
tna:	Low pass filter after the tanh based distortion. Value range is 0.0, 1.0
cav:	The amplitude of the cav reverb. Value range is 0.0 to infinity but will eventually hit the limiter.
cai:	The input or send into the cav reverb. Value range is 0.0, 1.0
cvt:	The cav reverb time. Value range is 0.0, 1.0
cvd:	The cav reverb dampening. Value range is 0.0, 1.0
cvl:	The cav low pass filter after the reverb. Value range is 0.0, 1.0
dfm:	A stereo distortion based on DFM1. This is the wet / dry. Value range is 0.0, 1.0
dfg:	This sets the gain of the dfm distortion. The value range is 0.0 to 999.0.
jpr:	JPverb wet mix, 0.0 to infinity
jpg:	JPverb input gain, 0.0 to 999.0
jts:	JPverb t60, approximate reverb time in seconds 0.0 to 1.0 where zero is about 0.1 seconds and 1.0 is about 60 seconds
jpd:	JPverb damp, Value range is 0.0, 1.0
jps:	JPverb room size, Value range is 0.0, 1.0
jed:	JPverb early diffusion, Value range is 0.0, 1.0
jmd:	JPverb modulation depth, Value range is 0.0, 1.0
jmf:	JPverb modulation frequency, Value range is 0.0, 1.0
jpl:	JPverb low multiplier, Value range is 0.0, 1.0
jpm:	JPverb mid multiplier, Value range is 0.0, 1.0
jph:	JPverb high multiplier, Value range is 0.0, 1.0
jlc:	JPverb low cut, Value range is 0.0, 1.0
jhc:	JPverb high cut, Value range is 0.0, 1.0

The parameters below aren't actually part of SuperClean, but are very useful to know about,
and, because SuperClean is running inside SuperCollider, we can use them.

dur:        The duration between events, range is a float above zero to infity, zero is infinitely fast, so, never do that.
midinote:   0 to 127. 60 is default. Interestingly accepts floats which allows for microtonality.
freq:       When we want to work with frequencies instead of midi note numbers as above, accepts integers 20 to 20000.
scale:      Choose scale, for example: Scale.harmonicMinor, add a tuning there like this: Scale.harmonicMinor(\sept1)
degree:     Negative infinity to infinity really but often, in the west, there will be seven degrees in scale.
octave:     Choose the octave. Range is zero to infinity really but a reasonable range is more like 1 to 6. Accepts floats!
ctranspose: Chromatic transpositon. All the keys on a piano. Range is something like integers between -63 and 64 but depends.
mtranspose: Modal transposition of degree within a scale. Works in combination with other keys like degree and scale.
harmonic:   Multiplies the frequency determined by midinote, typically to an overtone. https://en.wikipedia.org/wiki/Overtone

stepsPerOctave has no documentation that I can find. Very little is known about this parameter other than that it's default is 12.
Try commenting out that key in this example:

(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \fmx,
		dur: 1/8,
		pan: Pwhite(0.0, 1.0),
		degree: Pseq((0 .. 7), inf),
		stepsPerOctave: Pwhite(1, 12),
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

legato :     Like a variable soft cut dependent on dur where 1 is equal to dur. Only affects itself.
sustain:     Adds sustain by changing the timescale of the envelope. Can turn a drum into a drone. 0.01ish to infinity.


In the \fmx synth definition the envelope segments are expressed in
percentages. e4 through to e1 tell you how far into the note value that the
envelope should have reached it’s maximum level after the attack time, after
which the release time begins immediately. So an e1 value of 0.01 will yield a
1% duration for the attack and a 99% duration for the release. c4 through to c1
denote the curvature of the envelope segments. hr is the harmonicity ratio of
the operator. mi means modulation index, which is the modulation amount by
which that oscillator will modulate the next. The last oscillator (e1) doesn’t
have a modulation index value because it isn’t modulating anything else. The
first oscillator modulates itself with the mi1 parameter. SuperCollider has an
uncanny knack for delivering such clean synthesis, owing to negligible round
off errors in the calculation of waveforms at the lowest level. This becomes
especially important for me where modulation indexes are concerned. Without
this level of detail, FM can otherwise easily become a very round about way for
me to make white noise.

freq:
hr1:
hr2:
hr3:
hr4:
mi1:
mi2:
mi3:
mi4:
en1:
en2:
en3:
en4:
cu1:
cu2:
cu3:
cu4:


In the \drm synth definition you can change the tuning of the drum with tun.
Strange wrapping and nonlinear range. Start trying values around 1.  The fed
parameter controls the amount of feedback inside the oscillator. Value range is
0 to a lot where 0 is a sine, the higher up you go the noisier. The pew
parameter controls the space blaster to metal kickdrum morph. Lower values are
more space blaster like. Higher values sound tighter.

tun:
fed:
pew:


The \hat synth definition is a noise source through a filter and an envelope.
You can use tun in a weird way to provide some variation on the frequency.
bnd sweeps the filter.

tun:
bnd:


The \clp synth definition uses a full frequency range impulse that is run through
a narrow band-pass filter and a fast envelope for the clap's noise burst, and a
high-pass filter to provide some body at the onset of the hit.  Set the volume of
the body by using the tha parameter (thump amp), and control it's initial pitchbend
amount with bdy, and use bdt to set how long it takes to get there.  Thump's tuning
can also be adjusted relative to the main clap sound by usingthe tho key. Control the
character of the sound with the srp (sharpness) parameter, which allows you to tune
the claps, sounding maybe a bit more "real" somewhere between 0.3 and 0.35, and more
synthetic elsewhere. The srq parameter, the band-pass filter's resonance allows you to
dial in the tone a bit more. The dmp key controls a final LPF that acts a dampener for
the sound.

srp: (0, 1) parameter range
srq: (0, 1) parameter range
bdy: (0, 1) parameter range
tha: (0, 1) parameter range
tho: (0.01, 1) parameter range
dmp: (20, 20000) parameter range


The \kps synth definition Karplus-Strong physical modeling of a vibrating string,
using a delay line (CombL) excited by an intial pulse (Impulse)
freq or midinote controls the frequency. bnd is used for a pitch glide. Value range is -1 to 1.

freq:
bnd:
bnt:
bno:
bnc:


The \sin synth definition is a sine wave oscillator. It accepts freq and midinote
and parameters like those. It can also let you control the initial phase with the
iph parameter. This might not be very exciting since it is a sine wave and frequency
is either 100% phase cancelled out or not at all.

freq:
iph:
bnd:
bnt:
bno:
bnc:


The \saw synth definition is a saw wave oscillator. It accepts freq and midinote
and parameters like those. It can also let you control the initial phase with the
iph parameter. This might  potentially be very cool because you can then partially
phase out another saw wave. You can also control the width of the saw wave with
the wid parameter.

freq:
iph:
wid:
bnd:
bnt:
bno:
bnc:

The \sqr synth definition is a square wave oscillator. Same thing as above for the
parameters.

freq:
wid:
bnd:
bnt:
bno:
bnc:


The \dfd synth definition is a transient excited filter, the filter itself is noisy and can self oscillate
den: the density of transients.
res: the resonance of the filter. 1.0 is a tremendously narrow sweetspot. Range is 0.0 to 1.01.
typ: the type of filter, where 0.0 is low pass, and 1.0 is high pass.
nsl: the noise level. Range is 0.0 to infinity. Go easy here, as a little goes a very long way.
Please be advised that as this synthdef is dual mono, it does not respond to panning in any way.

freq:
den:
res:
typ:
nsl:


The \bow synth definition is a digital wave guide physical model of a bowed instrument.
frc: Force.
pos: Position.
gst: Gesture (envelope curvature).
idc: Inverse of DC decay time.
hfl: High frequency loss factor.
smp: String impedance.
ihf: Inharmonicity factor.

freq:
frc:
pos:
hlf:
bnd:
bnt:
bno:
bnc:


The \ixa synth definition is a kind of phase distortion based synth.
It has a lot of potential for timbral unfolding after initiation.
It builds on the work of Nathan Ho. Read more here: https://nathan.ho.name/posts/ixa-synthesis/
bes: slopeBelow speed.
ber: slopeBelow range.
abs: slopeAbove speed.
abr: slopeAbove range.
ths: threshold speed.
thr: threshold range.

freq:
bnd:
bnt:
bno:
bnc:


The \blp synth definition is a kind of additive synth that lets you add the number of harmonics.
freq:
nmh:
bnd:
bnt:
bno:
bnc:

There are also 32 six operator FM synths which I loosely based on the algorithms popularized by Yamaha.
They are called \fm0 to \fmv.
One important thing about these synths that I need you to know is that their internal envelope times are scaled by the sustain key.
Really good to keep that in mind when using these synths.
I care about you and I want you to have a good time here.
Understanding that the sustain key scales the internal envelopes of these synths is integral to that goal of you having a good time.
I also want to recommend that you do not use the atk, hld and rel keys on these synths.
They already have envelopes in there.
I think that if you use these synths with the added amplitude envelope added on top,
then you would be missing out on some gnarly FM envelope phenomena.
Just go nuts exploring the built in envelopes in the synths.
Check out my defaults.
Some of those values are quite extreme.
Just sit with it for a bit.
You'll get there.

Here are some code blocks which show the default values for each synth.
This means that you will get these sounds just by using these synthnames.
You are also free to overwrite any or all of these values at any time.
Below the code blocks showcasing the defaults are some examples that use these 6opFM synths together in various constellations.

(
Pdef(0,
	Pbind(*[
		type: \cln,
		snd: \fm0,
		amp: 0.5,
		hr1: 3,
		hr2: 3,
		hr3: 1,
		hr4: 5,
		hr5: 4,
		hr6: 2,
		mi1: 1.5,
		mi2: 0,
		mi3: 1,
		mi4: 0.5,
		mi5: 0.5,
		mi6: 3.0,
		en1: 0.0,
		en2: 0.0,
		en3: 0.04,
		en4: 0.05,
		en5: 0.0,
		en6: 0.0,
		cu1: 8,
		cu2: 200,
		cu3: 4,
		cu4: -2,
		cu5: -32,
		cu6: 8,
		tp1: 1.0,
		tp3: 1.0,
		dur: 1/5,
		wid: 1,
	])
).play;
)

(
Pdef(1,
	Pbind(*[
		type: \cln,
		snd: \fm1,
		amp: 0.5,
		hr1: 1,
		hr2: 1,
		hr3: 1,
		hr4: 1,
		hr5: 1,
		hr6: 1,
		mi1: 1.5,
		mi2: 1,
		mi3: 1,
		mi4: 1.5,
		mi5: 0.5,
		mi6: 1.0,
		en1: 0,
		en2: 0.01,
		en3: 0.02,
		en4: 0.03,
		en5: 0.04,
		en6: 0.05,
		cu1: 8,
		cu2: 6,
		cu3: 4,
		cu4: 2,
		cu5: 0,
		cu6: -2,
		tp1: 1.0,
		tp3: 1.0,
		dur: 1/2,
		wid: 1,
	])
).play
)

(
Pdef(2,
	Pbind(*[
		type: \cln,
		snd: \fm2,
		amp: 0.5,
		hr1: 1,
		hr2: 2,
		hr3: 1,
		hr4: 2,
		hr5: 3,
		hr6: 4,
		mi1: 1.5,
		mi2: 2,
		mi3: 0,
		mi4: 0.5,
		mi5: 2.0,
		mi6: 0.125,
		en1: 0.05,
		en2: 0.04,
		en3: 0.03,
		en4: 0.02,
		en5: 0.01,
		en6: 0.0,
		cu1: 3,
		cu2: 6,
		cu3: 2,
		cu4: 4,
		cu5: 1,
		cu6: 8,
		tp1: 1.0,
		tp4: 1.0,
		dur: 1/3
		wid: 1,
	])
).play
)

(
Pdef(3,
	Pbind(*[
		type: \cln,
		snd: \fm3,
		amp: 0.5,
		hr1: 1,
		hr2: 1,
		hr3: 1,
		hr4: 1,
		hr5: 1,
		hr6: 1,
		mi1: 1.0,
		mi2: 2.5,
		mi3: 1.0,
		mi4: 0.5,
		mi5: 2.5,
		mi6: 1.0,
		en1: 0.001,
		en2: 0.5,
		en3: 0.002,
		en4: 0.004,
		en5: 0.003,
		en6: 0.0,
		cu1: 0,
		cu2: -2,
		cu3: 0,
		cu4: -1,
		cu5: -6,
		cu6: -2,
		tp1: 1.0,
		tp3: 1.0,
		tp5: 1.0,
		dur: 1/4,
		wid: 1,
	])
).play
)

(
Pdef(4,
	Pbind(*[
		type: \cln,
		snd: \fm4,
		amp: 0.5,
		hr1: 1,
		hr2: 0,
		hr3: 3,
		hr4: 0,
		hr5: 5,
		hr6: 7,
		mi1: 0.5,
		mi2: 0.0,
		mi3: 1.0,
		mi4: 0.0,
		mi5: 0.5,
		mi6: 0.75,
		en1: 0.0,
		en2: 0.0,
		en3: 0.05,
		en4: 0.0,
		en5: 0.0,
		en6: 0.1,
		cu1: 0.25,
		cu2: 0,
		cu3: 0.5,
		cu4: 0,
		cu5: 5,
		cu6: -2,
		tp1: 1.0,
		tp3: 1.0,
		tp5: 1.0,
		dur: 1/5,
		wid: 1,
	])
).play;
)

(
Pdef(5,
	Pbind(*[
		type: \cln,
		snd: \fm5,
		amp: 0.5,
		hr1: 1,
		hr2: 3,
		hr3: 2,
		hr4: 4,
		hr5: 3,
		hr6: 5,
		mi1: 1.0,
		mi2: 1.0,
		mi3: 1.0,
		mi4: 1.0,
		mi5: 1.0,
		mi6: 1.0,
		en1: 0.0,
		en2: 0.25,
		en3: 0.2,
		en4: 0.35,
		en5: 0.75,
		en6: 0.45,
		cu1: 4.0,
		cu2: -4,
		cu3: 4.0,
		cu4: -4,
		cu5: 4.0,
		cu6: -4,
		tp1: 1,
		tp3: 1,
		tp5: 1,
		dur: 1/2,
		wid: 1,
	])
).play;
)

(
Pdef(6,
	Pbind(*[
		type: \cln,
		snd: \fm6,
		amp: 0.5,
		hr1: 2,
		hr2: 1,
		hr3: 1,
		hr4: 2,
		hr5: 1,
		hr6: 1,
		mi1: 1.0,
		mi2: 0.0,
		mi3: 4.0,
		mi4: 0.0,
		mi5: 4.0,
		mi6: 200.0,
		en1: 0.1,
		en2: 0.2,
		en3: 0.0,
		en4: 0.3,
		en5: 0.0,
		en6: 0.0,
		cu1: -2.0,
		cu2: -4.0,
		cu3: 64.0,
		cu4: 0.0,
		cu5: 0.0,
		cu6: -8.0,
		tp1: 1,
		tp3: 0.5,
		dur: 4/5,
		wid: 1,
	])
).play;
)

(
Pdef(7,
	Pbind(*[
		type: \cln,
		snd: \fm7,
		amp: 0.5,
		hr1: 1,
		hr2: 1,
		hr3: 2,
		hr4: 2,
		hr5: 2,
		hr6: 4,
		mi1: 1.0,
		mi2: 0.0,
		mi3: 0.3,
		mi4: 1.2,
		mi5: 3.0,
		mi6: 0.0,
		en1: 0.0,
		en2: 0.0,
		en3: 0.9,
		en4: 0.1,
		en5: 0.2,
		en6: 0.4,
		cu1: -2.0,
		cu2: 32.0,
		cu3: 1.0,
		cu4: 1.0,
		cu5: -2.0,
		cu6: 5.0,
		tp1: 0.8,
		tp3: 1.0,
		dur: 1/3,
		wid: 1,
	])
).play;
)

(
Pdef(8,
	Pbind(*[
		type: \cln,
		snd: \fm8,
		amp: 0.5,
		hr1: 3,
		hr2: 2,
		hr3: 4,
		hr4: 4,
		hr5: 5,
		hr6: 6,
		mi1: 1.0,
		mi2: 3.25,
		mi3: 0.125,
		mi4: 0.0,
		mi5: 3.0,
		mi6: 0.0,
		en1: 0.0,
		en2: 0.0,
		en3: 0.5,
		en4: 0.8,
		en5: 0.7,
		en6: 0.8,
		cu1: 0.0,
		cu2: 16.0,
		cu3: -2.0,
		cu4: -3.0,
		cu5: -4.0,
		cu6: -5.0,
		tp1: 0.4,
		tp3: 1.0,
		dur: 1/4,
		wid: 1,
	])
).play;
)

(
Pdef(9,
	Pbind(*[
		type: \cln,
		snd: \fm9,
		amp: 0.5,
		hr1: 1,
		hr2: 7,
		hr3: 6,
		hr4: 4,
		hr5: 5,
		hr6: 2,
		mi1: 1.0,
		mi2: 5.0,
		mi3: 9.0,
		mi4: 1.0,
		mi5: 0.0,
		mi6: 0.0,
		en1: 0.3,
		en2: 0.9,
		en3: 0.1,
		en4: 0.8,
		en5: 0.2,
		en6: 0.7,
		cu1: 2.0,
		cu2: -1.0,
		cu3: 8.0,
		cu4: -4.0,
		cu5: -8.0,
		cu6: -2.0,
		tp1: 0.75,
		tp4: 1.0,
		dur: 5/7,
		wid: 1,
	])
).play;
)

(
Pdef(10,
	Pbind(*[
		type: \cln,
		snd: \fma,
		amp: 0.5,
		hr1: 2,
		hr2: 1,
		hr3: 4,
		hr4: 1,
		hr5: 2,
		hr6: 3,
		mi1: 1.0,
		mi2: 1.0,
		mi3: 0.0,
		mi4: 1.5,
		mi5: 0.0,
		mi6: 2.0,
		en1: 0.5,
		en2: 0.6,
		en3: 0.7,
		en4: 0.0,
		en5: 0.05,
		en6: 0.06,
		cu1: -2.0,
		cu2: -128.0,
		cu3: -128.0,
		cu4: 32.0,
		cu5: -128.0,
		cu6: -128.0,
		tp1: 1.0,
		tp4: 1.0,
		dur: 7/5,
		wid: 1,
	])
).play;
)

(
Pdef(11,
	Pbind(*[
		type: \cln,
		snd: \fmb,
		amp: 0.5,
		hr1: 1,
		hr2: 2,
		hr3: 4,
		hr4: 6,
		hr5: 4,
		hr6: 2,
		mi1: 2.0,
		mi2: 4.0,
		mi3: 2.0,
		mi4: 0.0,
		mi5: 0.0,
		mi6: 0.0,
		en1: 0.9,
		en2: 0.8,
		en3: 0.7,
		en4: 0.6,
		en5: 0.5,
		en6: 0.4,
		cu1: 8.0,
		cu2: 8.0,
		cu3: 8.0,
		cu4: 8.0,
		cu5: 8.0,
		cu6: 8.0,
		tp1: 1.0,
		tp3: 1.0,
		dur: 9/5,
		wid: 1,
	])
).play;
)

(
Pdef(12,
	Pbind(*[
		type: \cln,
		snd: \fmc,
		amp: 0.5,
		hr1: 1,
		hr2: 1,
		hr3: 1,
		hr4: 1,
		hr5: 1,
		hr6: 1,
		mi1: 1.0,
		mi2: 0.0,
		mi3: 1.0,
		mi4: 0.0,
		mi5: 0.0,
		mi6: 10.0,
		en1: 0.0,
		en2: 0.0,
		en3: 0.0,
		en4: 0.0,
		en5: 0.0,
		en6: 1.0,
		cu1: 0.0,
		cu2: 0.0,
		cu3: 0.0,
		cu4: 0.0,
		cu5: 0.0,
		cu6: 0.0,
		tp1: 1.0,
		tp3: 1.0,
		dur: 11/5,
		wid: 1,
	])
).play;
)

(
Pdef(13,
	Pbind(*[
		type: \cln,
		snd: \fmd,
		amp: 0.5,
		hr1: 1,
		hr2: 3,
		hr3: 1,
		hr4: 1,
		hr5: 5,
		hr6: 1,
		mi1: 1.0,
		mi2: 0.0,
		mi3: 0.5,
		mi4: 0.0,
		mi5: 0.0,
		mi6: 200.0,
		en1: 0.8,
		en2: 0.2,
		en3: 0.7,
		en4: 0.3,
		en5: 0.6,
		en6: 0.4,
		cu1: -8.0,
		cu2: 16.0,
		cu3: -16.0,
		cu4: 8.0,
		cu5: 0.0,
		cu6: -8.0,
		tp1: 1.0,
		tp3: 1.0,
		dur: 1,
		wid: 1,
	])
).play;
)

(
Pdef(14,
	Pbind(*[
		type: \cln,
		snd: \fme,
		amp: 0.5,
		hr1: 3,
		hr2: 3,
		hr3: 2,
		hr4: 2,
		hr5: 3,
		hr6: 4,
		mi1: 1.0,
		mi2: 4.0,
		mi3: 1.0,
		mi4: 0.0,
		mi5: 0.0,
		mi6: 0.0,
		en1: 1/16,
		en2: 0,
		en3: 0.05,
		en4: 0,
		en5: 0,
		en6: 0,
		cu1: 8.0,
		cu2: -8.0,
		cu3: 32.0,
		cu4: -8.0,
		cu5: 2.0,
		cu6: -4.0,
		tp1: 1.0,
		tp3: 1.0,
		dur: 6/5,
		wid: 1,
	])
).play;
)

(
Pdef(15,
	Pbind(*[
		type: \cln,
		snd: \fmf,
		amp: 0.5,
		hr1: 1,
		hr2: 1,
		hr3: 1,
		hr4: 4,
		hr5: 3,
		hr6: 2,
		mi1: 1.0,
		mi2: 0.0,
		mi3: 1.0,
		mi4: 0.0,
		mi5: 1.0,
		mi6: 2000.0,
		en1: 0.0,
		en2: 0.0,
		en3: 0.0,
		en4: 0.0,
		en5: 0.0,
		en6: 0.0,
		cu1: 4.0,
		cu2: 6.0,
		cu3: 8.0,
		cu4: 10.0,
		cu5: 12.0,
		cu6: 128.0,
		tp1: 1.0,
		dur: 7/5,
		wid: 1,
	])
).play;
)

(
Pdef(16,
	Pbind(*[
		type: \cln,
		snd: \fmg,
		amp: 0.5,
		hr1: 1,
		hr2: 3,
		hr3: 2,
		hr4: 6,
		hr5: 4,
		hr6: 12,
		mi1: 1.0,
		mi2: 2.0,
		mi3: 2.0,
		mi4: 0.0,
		mi5: 2.0,
		mi6: 0.0,
		en1: 0.0,
		en2: 0.2,
		en3: 0.2,
		en4: 0.4,
		en5: 0.0,
		en6: 0.2,
		cu1: 2.0,
		cu2: 4.0,
		cu3: 4.0,
		cu4: 8.0,
		cu5: 1.0,
		cu6: 32.0,
		tp1: 1.0,
		dur: 8/5,
		wid: 1,
	])
).play;
)

(
Pdef(17,
	Pbind(*[
		type: \cln,
		snd: \fmh,
		amp: 0.5,
		hr1: 2,
		hr2: 1,
		hr3: 3,
		hr4: 4,
		hr5: 6,
		hr6: 8,
		mi1: 1.0,
		mi2: 0.0,
		mi3: 3.5,
		mi4: 0.8,
		mi5: 0.7,
		mi6: 0.0,
		en1: 0.0,
		en2: 0.05,
		en3: 0.1,
		en4: 0.15,
		en5: 0.2,
		en6: 0.25,
		cu1: 1.0,
		cu2: -3.0,
		cu3: 5.0,
		cu4: -7.0,
		cu5: 9.0,
		cu6: -11.0,
		tp1: 1.0,
		dur: Pseq([1/5], inf),
		wid: 1,
	])
).play;
)

(
Pdef(18,
	Pbind(*[
		type: \cln,
		snd: \fmi,
		amp: 0.5,
		hr1: 2,
		hr2: 1,
		hr3: 1,
		hr4: 2,
		hr5: 1,
		hr6: 1,
		mi1: 0.2,
		mi2: 1.0,
		mi3: 0.0,
		mi4: 0.3,
		mi5: 2.0,
		mi6: 4.0,
		en1: 0.0125,
		en2: 0.025,
		en3: 0.0375,
		en4: 0.05,
		en5: 0.0,
		en6: 0.0,
		cu1: 2.0,
		cu2: 4.0,
		cu3: 6.0,
		cu4: 8.0,
		cu5: 10.0,
		cu6: 300.0,
		tp1: 1.0,
		tp4: 1.0,
		tp5: 1.0,
		dur: Pseq([11/5], inf),
		wid: 1,
	])
).play;
)

(
Pdef(19,
	Pbind(*[
		type: \cln,
		snd: \fmj,
		amp: 0.5,
		hr1: 3,
		hr2: 4,
		hr3: 1,
		hr4: 2,
		hr5: 5,
		hr6: 3,
		mi1: 1.0,
		mi2: 1.0,
		mi3: 1.15,
		mi4: 1.0,
		mi5: 0.0,
		mi6: 0.0,
		en1: 0.5,
		en2: 0.6,
		en3: 0.7,
		en4: 0.0,
		en5: 0.1,
		en6: 0.2,
		cu1: 1.0,
		cu2: 2.0,
		cu3: 3.0,
		cu4: -4.0,
		cu5: 1.0,
		cu6: 4.0,
		tp1: 1.0,
		tp2: 1.0,
		tp4: 1.0,
		dur: Pseq([11/5], inf),
		wid: 1,
	])
).play;
)

(
Pdef(20,
	Pbind(*[
		type: \cln,
		snd: \fmk,
		amp: 0.5,
		hr1: 6,
		hr2: 3,
		hr3: 3,
		hr4: 1,
		hr5: 1,
		hr6: 2,
		mi1: 1.0,
		mi2: 1.0,
		mi3: 1.0,
		mi4: 1.0,
		mi5: 1.0,
		mi6: 0.0,
		en1: 0.16039591282606,
		en2: 0.18169086426497,
		en3: 0.19759377464652,
		en4: 0.20934272557497,
		en5: 0.27640253305435,
		en6: 0.29310788959265,
		cu1: -0.60202884674072,
		cu2: 2.3572835922241,
		cu3: -1.4189023971558,
		cu4: 2.00159740448,
		cu5: -3.5240240097046,
		cu6: 3.0169153213501,
		tp1: 1.0,
		tp2: 1.0,
		tp4: 1.0,
		tp5: 1.0,
		dur: Pseq([1/5], inf),
		wid: 1,
	])
).play;
)

(
Pdef(21,
	Pbind(
		type: \cln,
		snd: \fml,
		amp: 0.5,
		hr1: 2,
		hr2: 3,
		hr3: 4,
		hr4: 5,
		hr5: 6,
		hr6: 7,
		mi1: 1.0,
		mi2: 0.0,
		mi3: 1.0,
		mi4: 1.0,
		mi5: 1.0,
		mi6: 128.0,
		en1: 0.0,
		en2: 0.3,
		en3: 0.0,
		en4: 0.01,
		en5: 0.25,
		en6: 1.0,
		cu1: 2.0,
		cu2: 0.1,
		cu3: 0.9,
		cu4: 0.3,
		cu5: 0.6,
		cu6: 16.0,
		tp1: 1.0,
		tp3: 1.0,
		tp4: 1.0,
		tp5: 1.0,
		dur: Pseq([1/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(22,
	Pbind(
		type: \cln,
		snd: \fmm,
		amp: 0.5,
		hr1: 0.5,
		hr2: 1,
		hr3: 2,
		hr4: 0.25,
		hr5: 0.5,
		hr6: 0.125,
		mi1: 0.0,
		mi2: 0.75,
		mi3: 0.0,
		mi4: 2.0,
		mi5: 3.0,
		mi6: 3.0,
		en1: 0.0,
		en2: 1/16,
		en3: 1/15,
		en4: 1/14,
		en5: 0.0,
		en6: 0.0,
		cu1: 8.0,
		cu2: 2.0,
		cu3: 2.0,
		cu4: 2.0,
		cu5: 4.0,
		cu6: 4.0,
		tp1: 1.0,
		tp2: 1.0,
		tp4: 0.25,
		tp5: 0.25,
		dur: Pseq([1/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(23,
	Pbind(
		type: \cln,
		snd: \fmn,
		amp: 0.5,
		hr1: 0.25,
		hr2: 0.5,
		hr3: 1.5,
		hr4: 0.5,
		hr5: 2,
		hr6: 0.5,
		mi1: 0.0,
		mi2: 0.0,
		mi3: 1.0,
		mi4: 1.0,
		mi5: 1.0,
		mi6: 11.0,
		en1: 1/8,
		en2: 1/4,
		en3: 1/16,
		en4: 1/2,
		en5: 1/32,
		en6: 0.0,
		cu1: 1.0,
		cu2: 2.0,
		cu3: 4.0,
		cu4: 8.0,
		cu5: 16.0,
		cu6: 32.0,
		tp1: 1.0,
		tp2: 1.0,
		tp3: 1.0,
		tp4: 1.0,
		tp5: 1.0,
		dur: Pseq([1/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(24,
	Pbind(
		type: \cln,
		snd: \fmo,
		amp: 0.5,
		hr1: 2,
		hr2: 3,
		hr3: 4,
		hr4: 5,
		hr5: 6,
		hr6: 7,
		mi1: 100.0,
		mi2: 300.0,
		mi3: 150.0,
		mi4: 1.0,
		mi5: 1.0,
		mi6: 200.0,
		en1: 0.01478,
		en2: 0.2455789,
		en3: 0.035678,
		en4: 0.439350,
		en5: 0.05279,
		en6: 0.690743,
		cu1: 8.0,
		cu2: 8.0,
		cu3: 8.0,
		cu4: 8.0,
		cu5: 8.0,
		cu6: 8.0,
		tp1: 1.0,
		tp2: 1.0,
		tp3: 1.0,
		tp4: 1.0,
		tp5: 1.0,
		dur: Pseq([1/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(25,
	Pbind(
		type: \cln,
		snd: \fmp,
		amp: 0.5,
		hr1: 2,
		hr2: 3,
		hr3: 2,
		hr4: 0.5,
		hr5: 0.25,
		hr6: 3,
		mi1: 0.0,
		mi2: 1.0,
		mi3: 0.0,
		mi4: 1.0,
		mi5: 0.0,
		mi6: 14.0,
		en1: 0.25,
		en2: 0.25,
		en3: 0.25,
		en4: 0.0,
		en5: 0.03125,
		en6: 0.0,
		cu1: 4.0,
		cu2: 4.0,
		cu3: 4.0,
		cu4: 2.0,
		cu5: 4.0,
		cu6: 8.0,
		tp1: 1.0,
		tp2: 1.0,
		tp4: 1.0,
		dur: Pseq([3/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(26,
	Pbind(
		type: \cln,
		snd: \fmq,
		amp: 0.5,
		hr1: 2,
		hr2: 2,
		hr3: 2,
		hr4: 0.5,
		hr5: 0.25,
		hr6: 3,
		mi1: 0.0,
		mi2: 0.5,
		mi3: 0.75,
		mi4: 2.0,
		mi5: 0.0,
		mi6: 0.0,
		en1: 0.1,
		en2: 0.2,
		en3: 0.3,
		en4: 0.4,
		en5: 0.5,
		en6: 0.0,
		cu1: 1.0,
		cu2: 2.0,
		cu3: 4.0,
		cu4: 4.0,
		cu5: 4.0,
		cu6: 1.0,
		tp1: 1.0,
		tp2: 1.0,
		tp4: 1.0,
		dur: Pseq([1/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(27,
	Pbind(
		type: \cln,
		snd: \fmr,
		amp: 0.5,
		hr1: 0.25,
		hr2: 0.5,
		hr3: 1,
		hr4: 2,
		hr5: 4,
		hr6: 0.5,
		mi1: 1.0,
		mi2: 0.0,
		mi3: 1.0,
		mi4: 10.0,
		mi5: 10.0,
		mi6: 0.0,
		en1: 0.0,
		en2: 0.0,
		en3: 0.0,
		en4: 0.0,
		en5: 0.0,
		en6: 0.0,
		cu1: 2.0,
		cu2: 4.0,
		cu3: 6.0,
		cu4: 8.0,
		cu5: 10.0,
		cu6: 12.0,
		tp1: 1.0,
		tp3: 1.0,
		tp6: 1.0,
		dur: Pseq([11/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(28,
	Pbind(
		type: \cln,
		snd: \fms,
		amp: 0.5,
		hr1: 1.0,
		hr2: 0.5,
		hr3: 0.25,
		hr4: 1.0,
		hr5: 0.5,
		hr6: 0.25,
		mi1: 0.25,
		mi2: 1.125,
		mi3: 1.0,
		mi4: 0.0,
		mi5: 1.0,
		mi6: 1.5,
		en1: 0.16,
		en2: 0.08,
		en3: 0.04,
		en4: 0.02,
		en5: 0.01,
		en6: 0.0,
		cu1: 1.2,
		cu2: 3.4,
		cu3: 5.6,
		cu4: 7.8,
		cu5: 5.6,
		cu6: 8.9,
		tp1: 1.0,
		tp2: 1.0,
		tp3: 1.0,
		tp5: 1.0,
		dur: Pseq([1/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(29,
	Pbind(
		type: \cln,
		snd: \fmt,
		amp: 0.5,
		hr1: 0.5,
		hr2: 2,
		hr3: 4,
		hr4: 0.5,
		hr5: 0.25,
		hr6: 0.25,
		mi1: 0.75,
		mi2: 0.5,
		mi3: 0.75,
		mi4: 2.0,
		mi5: 100.0,
		mi6: 0.5,
		en1: 0.0,
		en2: 0.0,
		en3: 0.01,
		en4: 0.0,
		en5: 0.0,
		en6: 0.0,
		cu1: 2.0,
		cu2: 4.0,
		cu3: 0.0,
		cu4: -4.0,
		cu5: -8.0,
		cu6: 2.0,
		tp1: 1.0,
		tp2: 1.0,
		tp3: 0.5,
		tp6: 2.0,
		dur: Pseq([1/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(30,
	Pbind(
		type: \cln,
		snd: \fmu,
		amp: 0.5,
		hr1: 0.25,
		hr2: 0.5,
		hr3: 1.0,
		hr4: 1.5,
		hr5: 3.0,
		hr6: 2.0,
		mi1: 2.0,
		mi2: 1.5,
		mi3: 1.75,
		mi4: 0.5,
		mi5: 1.5,
		mi6: 10.0,
		en1: 0.0,
		en2: 0.3,
		en3: 0.2,
		en4: 0.1,
		en5: 0.5,
		en6: 0.4,
		cu1: 4.0,
		cu2: 2.0,
		cu3: 6.0,
		cu4: 3.0,
		cu5: 8.0,
		cu6: 5.0,
		tp1: 1.0,
		tp2: 1.0,
		tp3: 1.0,
		tp4: 1.0,
		tp5: 1.0,
		dur: Pseq([6/5], inf),
		wid: 1,
	)
).play;
)

(
Pdef(31,
	Pbind(
		type: \cln,
		snd: \fmv,
		amp: 0.5,
		hr1: 0.25,
		hr2: 0.5,
		hr3: 1.0,
		hr4: 2.0,
		hr5: 4.0,
		hr6: 8.0,
		mi1: 0.0,
		mi2: 4.0,
		mi3: 8.0,
		mi4: 16.0,
		mi5: 32.0,
		mi6: 64.0,
		en1: 0.0,
		en2: 0.0625,
		en3: 0.125,
		en4: 0.25,
		en5: 0.5,
		en6: 1.0,
		cu1: 0.0,
		cu2: 2.0,
		cu3: 4.0,
		cu4: 8.0,
		cu5: 16.0,
		cu6: 32.0,
		tp1: 1.5,
		tp2: 0.1,
		tp3: 0.05,
		tp4: 0.1,
		tp5: 0.1,
		tp6: 0.25,
		dur: Pseq([13/5], inf),
		wid: 1,
	)
).play;
)

( // all the single carriers
Pdef(0,
	Pseed(9299,
		Pbind(
			type: Pseed(0, Pwrand2([\cln, \], [1, 2], inf)),
			snd: Pxshuf([\fmf, \fmg, \fmh], inf),
			dur: (1 / Phprand(0.0001, 11.0)).trace,
			amp: Pexprand(0.25, 1.25),
			pan: Pmeanrand(0.0, 1.0),
			sustain: Pkey(\dur) * Pexprand(9, 29),
			scale: Pdup(Pseed(1, Pexprand(9, 99)), Pxshuf([
				Scale.harmonicMinor(\sept2),
				Scale.minor(\sept1),
				Scale.major(\just),
				Scale.mixolydian,
			], inf)),
			degree: Plprand(0, 7).unique,
			octave: Pxshuf((2 .. 6), inf),
			jpr: 1,
		)
	)
).play
)

( // all 32 6opFM synths with defaults and subtle tap morph on all taps
Pdef(0,
    Pseed(9990,
        Pbind(
            type: Pwrand2([\cln, \], [11, 1], inf),
            snd: Pxshuf([
                \fm0, \fm1, \fm2, \fm3, \fm4, \fm5, \fm6, \fm7, \fm8, \fm9,
                \fma, \fmb, \fmc, \fmd, \fme, \fmf, \fmg, \fmh, \fmi, \fmj,
                \fmk, \fml, \fmm, \fmn, \fmo, \fmp, \fmq, \fmr, \fms, \fmt,
                \fmu, \fmv,
            ], inf),
            amp: Pdup(Pexprand(1, 19), Pexprand(0.125, 0.75)),
            pan: Pseq([Pmeanrand(0.0, 1.0, 1), Pexprand(1.0, 1.5, 1) - 1, 1.5 - Pexprand(0.5, 1.0, 1)], inf),
            jpr: 0.3,
            jpg: Pseg(Pexprand(0.3, 3.0), Pwhite(0.1, 4.0), \lin, inf),
            jps: Pseg(1.9 - Pexprand(0.9, 1.0), 10.1 - Pexprand(0.1, 10.0), \lin, inf),
            dur: Pwhite(1.0, 2.0) / Pseg(Pexprand(1, 64), Pwhite(0.1, 4.0), \sin, inf),
            stretch: Pexprand(0.5, 2.0),
            scale: Pdup(Pexprand(9, 999), Pxshuf([
                Scale.major(\just),
                Scale.minor(\sept1),
                Scale.harmonicMinor(\sept2),
                Scale.minorPentatonic,
                Scale.harmonicMajor,
                Scale.mixolydian,
                Scale.phrygian,
                Scale.lydian,
                Scale.locrian,
                Scale.pelog,
            ], inf)),
            tp1: Pseg(1.5 - Pexprand(0.5, 1.0), Pwhite(10.0, 40.0), \wel, inf).trace,
            tp2: Pseg(1.5 - Pexprand(0.5, 1.0), Pwhite(10.0, 40.0), \wel, inf),
            tp3: Pseg(1.5 - Pexprand(0.5, 1.0), Pwhite(10.0, 40.0), \wel, inf),
            tp4: Pseg(1.5 - Pexprand(0.5, 1.0), Pwhite(10.0, 40.0), \wel, inf),
            tp5: Pseg(1.5 - Pexprand(0.5, 1.0), Pwhite(10.0, 40.0), \wel, inf),
            tp6: Pseg(1.5 - Pexprand(0.5, 1.0), Pwhite(10.0, 40.0), \wel, inf),
            degree: Pdup(Pexprand(4, 11), Plprand(-14, 35).unique),
            hpf: Pseg(Pdup(2, Pexprand(20, 200).asInteger.unique), Pwhite(0.1, 4.0), \wel, inf),
            sustain: Pexprand(0.3, 2.0),
        )
    )
).play
)
