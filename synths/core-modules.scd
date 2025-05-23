/*
CORE MODULES
(REQUIRE: CORE EFFECTS)
Core Modules: these are called for each event,
and they represent the list of possible (effect) synths on the event level
Usually, they correspond to a SynthDef (here in core-synths), you could call any function in them
They will be called when the test is fulfilled (e.g. ~amp.notNil)
*/

/*
The sound source to be filtered by later stages (modules)
This could be:
- a sample that is played
- a generic synth, which allows us to embed a SynthDef name in a pattern next to sample names
A SynthDef could receive any number of the parameters in the event, e.g.
sustain, spd, bgn, end, pan, bnd
it ought to use "out" as bus output argument.
the diversion is a hook to add an arbitrary function instead of a synthdef.
*/
(

~clean.addModule(\sound,
	{ |cleanEvent|
		if(~diversion.value.isNil) {
			if(~buffer.notNil) {
				// arguments could be omitted using getMsgFunc, but to make it easier to understand, we write them out
				cleanEvent.sendSynth(~instrument,  [
					bufnum: ~buffer,
					sustain: ~sustain,
					spd: ~spd,
					freq: ~freq,
					endspd: ~endspd,
					bgn: ~bgn,
					end: ~end,
					lop: ~lop,
					pan: ~pan,
					out: ~out
				])
			} {
				if(~instrument.isNil) {
					"module 'sound': instrument not found: %".format(~sound).postln
				} {
					// here, we derive the arguments as necessary from the environment
					cleanEvent.sendSynth(~instrument, ~argNames)
				}
			}
		}
});

/*
these function as effects on the input of the synth or sample (see SynthDefs in core-synths)
they respond to the existence of a value for one of the parameters
*/

~clean.addModule(\out_to,
	{ |cleanEvent|
		var busses = ~clean.audioRoutingBusses;
		var bus = busses.wrapAt(~to.asInteger);
		cleanEvent.sendSynth(\clean_out ++ ~numChannels,
			[
				to: bus.index,
				out: ~out
			]
		)
}, { ~to.notNil });

// # from 3 # toArg "freq"
// synth needs to have an audio rate control.

~clean.addModule(\map_from,
	{ |cleanEvent|
		var busses = ~clean.audioRoutingBusses;
		var bus = if(~from.isNil) { busses.at(0) } { busses.wrapAt(~from.asInteger) };
		~server.sendMsg(
			"/n_mapan",
			~synthGroup,
			~toArg,
			bus.index,
			~clean.numChannels
		)
}, { ~toArg.notNil });
);
