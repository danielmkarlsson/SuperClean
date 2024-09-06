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
dla:	Delay amplitude. Value range is 0.0 to infinity.
dlf:	Delay feedback, proly good to think of 0.94 as the max sane value, although the value range is actually 0.0 to 1.0
dlt:	Delay time, value range is a very low float to 16.0
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

hal:	A hall reverb, this is the wet parameter, or put another way, the amplitude of the reverb. Value range is 0.0, 1.0
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