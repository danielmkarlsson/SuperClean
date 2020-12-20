/*

CORE MODULES
(REQUIRE: CORE SYNTHS)

Core Modules: these are called for each event from tidal,
and they represent the list of possible (effect) synths on the event level

Usually, they correspond to a SynthDef (here in core-synths), you could call any function in them
They will be called when the test is fulfilled (e.g. ~amp.notNil)

You can't currently add your own, because Tidal needs to support this extension first.

*/



/*
The sound source to be filtered by later stages (modules)

This could be:

- a sample that is played
- a generic synth, which allows us to embed a SynthDef name in a tidal pattern next to sample names

A SynthDef could receive any number of the parameters in the event, e.g.
sustain, spd, endspd, bgn, end, pan, accelerate, offset, cps

it ought to use "out" as bus output argument.

the diversion is a hook to add an arbitrary function instead of a synth def.
this may be refactored later.
*/
(

~clean.addModule('sound',
	{ |cleanEvent|
		if(~diversion.value.isNil) {
			if(~buffer.notNil) {
				// argumets could be omitted using getMsgFunc, but for making it easier to understand, we write them out
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
					// here, we just derive the arguments as necessary from the environment
					cleanEvent.sendSynth(~instrument, ~argNames)
				}
			}
		}
});


/*
these function as effects on the input of the synth or sample (see SynthDefs in core-synths)
they respond to the existence of a value for one of the tidal parameters
*/


~clean.addModule('out_to',
	{ |cleanEvent|
		var busses = ~clean.audioRoutingBusses;
		var bus = busses.wrapAt(~to.asInteger);
		cleanEvent.sendSynth("clean_out" ++ ~numChannels,
			[
				to: bus.index,
				out: ~out
			]
		)
}, { ~to.notNil });



// # from 3 # toArg "freq"
// synth needs to have an audio rate control.
// it would be nice to be able to map several arguments

~clean.addModule('map_from',
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

~clean.addModule('shape',
	{ |cleanEvent|
		cleanEvent.sendSynth("clean_shape" ++ ~numChannels,
			[
				shape: ~shp,
				out: ~out
		])

}, { ~shp.notNil });

~clean.addModule('hpf',
	{ |cleanEvent|
		cleanEvent.sendSynth("clean_hpf" ++ ~numChannels,
			[
				hcutoff: ~hpf,
				hresonance: ~hpq,
				out: ~out
		])

}, { ~hpf.notNil });

~clean.addModule('bpf',
	{ |cleanEvent|
		cleanEvent.sendSynth("clean_bpf" ++ ~numChannels,
			[
				bandqf: ~bandf,
				bandq: ~bandq,
				out: ~out
		])

}, { ~bandqf.notNil });

~clean.addModule('crush',
	{ |cleanEvent|
		cleanEvent.sendSynth("clean_crush" ++ ~numChannels,
			[
				crush: ~cru,
				out: ~out
		])

}, { ~cru.notNil });


~clean.addModule('coarse',
	{ |cleanEvent|
		cleanEvent.sendSynth("clean_coarse" ++ ~numChannels,
			[
				coarse: ~crs,
				out: ~out
		])

}, { ~crs.notNil and: { ~crs > 1 } }); // coarse == 1 => full rate

~clean.addModule('lpf',
	{ |cleanEvent|
		cleanEvent.sendSynth("clean_lpf" ++ ~numChannels,
			[
				cutoff: ~lpf,
				resonance: ~lpq,
				out: ~out
		])

}, { ~lpf.notNil });

~clean.addModule('envelope',
	{ |cleanEvent|
		cleanEvent.sendSynth('clean_envelope' ++ ~numChannels,
			[
				attack: ~atk,
				hold: ~hld,
				release: ~rel,
				crv: ~crv,
				out: ~out
		])
}, { ~atk.notNil or: { ~rel.notNil }});


~clean.addModule('tremolo',
	{ |cleanEvent|
		cleanEvent.sendSynth('clean_tremolo' ++ ~numChannels,
			[
				tremolorate: ~trr,
				tremolodepth: ~trd,
				out: ~out
		])
}, { ~trr.notNil });

// Phaser audio DSP effect declaration
~clean.addModule('phaser',
	{ |cleanEvent|
		cleanEvent.sendSynth('clean_phaser' ++ ~numChannels,
			[
				phaserrate: ~phr,
				phaserdepth: ~phd,
				out: ~out
		])
}, { ~phr.notNil });

);
