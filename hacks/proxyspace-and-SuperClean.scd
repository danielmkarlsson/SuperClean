// if the default startup file uses the default current Environment, you might need a little trick to use ProxySpace directly.
// when you switch to a different file, your environment could be the default one.
(
if(currentEnvironment.isKindOf(ProxySpace).not) {
	q = currentEnvironment;
	p = ProxySpace(~clean.server).linkDoc;
};
);

~out = { BrownNoise.ar(0.2 ! 2) };
~out.play;

~out.stop;

// route the clean output into the ProxySpace
(
~cleanOut.ar(q[\clean].numChannels);
q[\clean].auxs[0].outBus = ~cleanOut.bus;
)

// try to use it
~out.play;
~out = { RLPF.ar(~cleanOut.ar, SinOsc.ar([0.1, 0.11]).exprange(400, 10000), 0.01) };

// mix
ProxyMixer(p);

// if you need to access this ProxySpace in another document, you can do it by linking p there:

p.linkDoc;