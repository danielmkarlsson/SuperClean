/*
This may not be a complete list of parameter names.
The value range for the below parameters is 0.0 to 1.0 unless otherwise indicated

snd         sample or synth
num         number, which sample in a folder or which note if you are using a synth
pan         Pans the sound, 0.0 to 1.0.
shp         This is like a distortion, goes to 0.999999, does not accept 1 (I need to fix that)
amp         Make it louder! Can go above one to lean into the compressor
spd         The speed at which to play back the sample
atk         The attack time of the envelope
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
dlf         Delay feedback
dlt         Delay time, value range is a very low float to 4.0
rin         Set the amplitude of the input to the reverb
rev         Reverb time (or room size, if we can imagine that)
dry         Decrease the amplitude of the reverb
bgn         Where in the file to begin playing back the file
end         Where in the file to end playing back the file
bnd         Change the playback speed of the file while its running, accepts positive and negative values
lop         How many times to loop the file, takes integers, work in consort with the envelope parameters
cut         Cut groups, cuts itself as well as other things in the same cut group. Rougher edges than leagato in terms of sound
aux         An auxiliary output
trr         Tremolo Rate
trd         Tremeolo depth
freq        When working with synths and we want to work with frequencies instead of midi note numbers as above, accepts integers 20 to 20000.
legato      Like a variable soft cut dependent on dur where 1 is dur

The last two are actually not part of SuperClean but very useful and because SUperClean is running inside SuperClean we get to use them.

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
