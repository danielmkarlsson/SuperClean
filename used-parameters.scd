/*
This may not be a complete list of parameter names.

s           sample or sound or synth
n           number, which sample in a folder or which note if you are using a synth
pan         Pans the sound, 0.0 to 1.0.
shp         This is like a distortion, goes to 0.999999, does not accept 1 (I need to fix that)
gain        Make it louder! Can go above one to lean into the compressor
speed       The speed at which to play back the sample
atk         The attack time of the envelope
hld         The hold time of the envelope
rel         The release time of the envelope
crv         The curvature of the envelope, swings both ways. That is to say it uses both positive and negative values
lpf         Low pass filter
hpf         High pass filter
bpf         Band pass filter
lpq         Low pass filter resonance
hpq         High pass filter resonance
bpq         Band pass filter resonance
dla         Delay amplitude
dlf         Delay feedback
dlt         Delay time
room        Room is one of three reverb parameters
size        This is the other reverb parameter
dry         Decrease the amplitude of the reverb
freeze      FFT Freeze
enhance     FFT
smear       FFT
begin       Where in the file to begin playing back the file, the value range is 0.0 to 1.0
end         Where in the file to end playing back the file, the value range is 0.0 to 1.0
accelerate  Change the playback speed of the file while its running, accepts positive and negative values
loop        How many times to loop the file, takes integers, work in consort with the envelope parameters
legato      Like a variablöe soft cut dependent on dur where 1 is dur
cut         Cut groups, cuts itself as well as other things in the same cut group. rougher edges than leagato in terms of sound
orbit       Should really be called aux (I need to fix that)
trr         Tremolo Rate
trd         Tremeolo depth
freq        When working with a synth we might sometimes want to work with frequencies instead of midi note numbers as above, accepts integers 20 to 20000.

In the \fmx synth definition the envelope segments are expressed in
percentages. e4 through to e1 tell you how far into the note value that the
envelope should have reached it’s maximum level after the attack time, after
which the release time begins immediately. So an e1 value of 0.01 will yield a
1% duration for the attack and a 99% duration for the release. c4 through to c1
denote the curvature of the envelope segments. hr is the harmonicity ratio of
the operator. mi means modulation index, which is the modulation amount by
which that oscillator will modulate the next. The last oscillator (e1) doesn’t
have a modulation index value because it isn’t modulating anything else.
SuperCollider has an uncanny knack for delivering such clean synthesis, owing
to negligible round off errors in the calculation of waveforms at the lowest
level. This becomes especially important for me where modulation indexes are
concerned. Without this level of detail, FM can otherwise become a very round
about way for me to make white noise.
