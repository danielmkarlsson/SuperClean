/*
This may not be a complete list of parameter names.
The value range for the below parameters is 0.0 to 1.0 unless otherwise indicated

snd         Sample folder or synth name
num         Number, which sample in a folder or which note if you are using a synth, 0 is midinote 60
pan         Pans the sound, 0.0 to 1.0.
shp         This is like a distortion, goes to 0.999999, does not accept 1 (I need to fix that)
amp         Make it louder! Can go above one to lean into the limiter
spd         The speed at which to play back the sample, default is 1.0, negative numbers play the sample backwards, slower playback rates closer to 0
atk         The attack time of the envelope, the envelope parameters expressed in seconds, 1.0 here means a one second fade in time
hld         The hold time of the envelope
rel         The release time of the envelope
crv         The curvature of the envelope, swings both ways. That is to say it uses both positive and negative values, try values between -8 to 8
lpf         Low pass filter, value range is 20 to 20000
hpf         High pass filter, value range is 20 to 20000
bpf         Band pass filter, value range is 20 to 20000
lpq         Low pass filter resonance
hpq         High pass filter resonance
bpq         Band pass filter resonance
dla         Delay amplitude
dlf         Delay feedback, proly best to think of 0.94 as the max sane value
dlt         Delay time, value range is a very low float to 4.0
rin         Set the amplitude of the input to the reverb
rev         Reverb time (or room size, if we can imagine that)
dry         Decrease the amplitude of the reverb
bgn         Where in the file to begin playing back the file
end         Where in the file to end playing back the file
bnd         Change the playback speed of the file while its running, accepts positive and negative values. Also can do detune or bends of synths, try it
lop         How many times to loop the file, takes integers, work in consort with the envelope parameters
cut         Cut groups, cuts itself as well as other things in the same cut group. Rougher edges than leagato in terms of sound
aux         An auxiliary output, you can use these for different outputs or same output with different effects depending on your startup file
trr         Tremolo rate
trd         Tremeolo depth
freq        When working with synths and we want to work with frequencies instead of midi note numbers as above, accepts integers 20 to 20000.
legato      Like a variable soft cut dependent on dur where 1 is dur
sustain     Adds sustain to synths by changing the timescale of the envelope. Can turn a drum into a drone. Value range is a very small value above 0 to infinity

The last two are actually not part of SuperClean but very useful and because SuperClean is running inside SuperClean we get to use them.

In the \fmx synth definition the envelope segments are expressed in
percentages. e4 through to e1 tell you how far into the note value that the
envelope should have reached it’s maximum level after the attack time, after
which the release time begins immediately. So an e1 value of 0.01 will yield a
1% duration for the attack and a 99% duration for the release. c4 through to c1
denote the curvature of the envelope segments. hr is the harmonicity ratio of
the operator. mi means modulation index, which is the modulation amount by
which that oscillator will modulate the next. The last oscillator (e1) doesn’t
have a modulation index value because it isn’t modulating anything else. The
first oscillator modulates itself with the fb parameter.  SuperCollider has an
uncanny knack for delivering such clean synthesis, owing to negligible round
off errors in the calculation of waveforms at the lowest level. This becomes
especially important for me where modulation indexes are concerned. Without
this level of detail, FM can otherwise easily become a very round about way for
me to make white noise.

In the \drm synth definition you can change the tuning of the drum with tun.
This value range maps around when it reaches it's maximum. Try values around 1.
The fdb parameter controls the amount of feedback inside the oscillator. Value range is 0 to a lot where 0 is a sine and the higher up you go the noisier.




