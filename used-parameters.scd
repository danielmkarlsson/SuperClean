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
lhf         Low & high pass filter combo where 0.5 does nothing, 0.0 sets the lpf to 20hz and 1.0 sets the hpf to 20000  
dla         Delay amplitude  
dlf         Delay feedback, proly best to think of 0.94 as the max sane value  
dlt         Delay time, value range is a very low float to 4.0  
rin         Set the amplitude of the input to the reverb  
rev         Reverb time (or room size, if we can imagine that)  
dry         Decrease the amplitude of the reverb  
bgn         Where in the file to begin playing back the file  
end         Where in the file to end playing back the file  
bnd         Change the playback speed of the file while its running, accepts positive and negative values. Also can do detune or bends of synths, try it  
lop         How many times to loop the file, takes integers, works in consort with the envelope parameters  
cut         Cut groups, cuts itself as well as other things in the same cut group. Rougher edges than leagato in terms of sound  
aux         An auxiliary output, you can use these for different outputs or same output with different effects depending on your startup file  
rma         Ringmodulation wet  
rmf         Ringmodulation frequency  
rdf         The frequency to glissando in from, the d might be thought of as standing for detune, range is 20 to 20000  
rdt         The time it takes to glissando from the detune frequency which can be above or below rmf, range is 20 to 20000  
smr         spectral smear  
scm         spectral scramble  
enh         spectral enhance  
dark        controls the wet mix of a dark reverb  

midinote    0 to 127. 60 is default. Interestingly accepts floats which allows for microtonality  
freq        When working with synths and we want to work with frequencies instead of midi note numbers as above, accepts integers 20 to 20000  
scale       Choose scale, for example: Scale.harmonicMinor, can also let you tag on a tuning there like this: Scale.harmonicMinor.tuning_(Tuning.sept1)  
degree      Choose degrees. Zero to infinity really but proly there will be seven degrees in scale  
legato      Like a variable soft cut dependent on dur where 1 is equal to dur. This is unlike cut in that it only affects itself  
sustain     Adds sustain to synths by changing the timescale of the envelope. Can turn a drum into a drone. Value range is a very small value above 0 to infinity 
stretch     Scales durations, 1 is default, 2 is half speed, can not handle 0 because it is infinitely fast  

/rest        A silent event. For example `type: Pseq([\cln, \rest],inf)` Every other event is a rest. You can also use `\r` for rest. Less typing is nice.  


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
Strange wrapping and nonlinear range. Start trying values around 1.  
The fdb parameter controls the amount of feedback inside the oscillator.  
Value range is 0 to a lot where 0 is a sine, the higher up you go the noisier.  
The pew parameter controls teh space blaster to metal kickdrum morph.  
Lower values are more space blaster like. Higher values sound tighter.  

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
phase out  another saw wave. You can also control the width of the saw wave with  
the wid parameter.

freq  
iph  
wid  

The \sqr synth definition is a square wave oscillator. Same thing as above for the  
parameters.  

freq  
iph  
wid  


