/*

An aux encapsulates a continuous state that affects all sounds played in it.
It has default parameters for all sounds, which can be set, e.g. pan, and which can be overridden from tidal.
Its globalEffects are e.g. delay, reverb, and also the monitor which handles the audio output routing.
You can add and remove effects at runtime.

Settable parameters are also:

- fadeTime (fade in and out of each sample grain)
- amp (amp)
- minSustain (samples shorter than that are dropped).
- outBus (channel offset for the audio output)

Via the defaultParentEvent, you can also set parameters (use the set message):

- lag (offset all events)
- lock (if set to 1, syncs delay times with cps)


*/


CleanAux {

	var <clean,  <outBus, <auxIndex;
	var <server;
	var <synthBus, <globalEffectBus, <dryBus;
	var <group, <globalEffects, <cutGroups;
	var <>minSustain;


	var <>defaultParentEvent;

	*new { |clean, outBus, auxIndex = 0|
		^super.newCopyArgs(clean, outBus, auxIndex).init
	}

	init {
		server = clean.server;
		if(server.serverRunning.not) {
			Error("SuperColldier server '%' not running. Couldn't start CleanAux".format(server.name)).warn;
			^this
		};
		group = server.nextPermNodeID;
		cutGroups = IdentityDictionary.new;
		synthBus = Bus.audio(server, clean.numChannels);
		dryBus = Bus.audio(server, clean.numChannels);
		globalEffectBus = Bus.audio(server, clean.numChannels);
		minSustain = 8 / server.sampleRate;
		this.initDefaultGlobalEffects;
		this.initNodeTree;
		this.makeDefaultParentEvent;

		ServerTree.add(this, server); // synth node tree init
		CmdPeriod.add(this);
	}

	initDefaultGlobalEffects {
		this.globalEffects = [
			// all global effects sleep when the input is quiet for long enough and no parameters are set.
			GlobalCleanEffect(\clean_delay, [\delaytime, \delayfeedback, \delaySend, \delayAmp, \lock, \cps]),
			GlobalCleanEffect(\clean_reverb, [\size, \room, \dry]),
			GlobalCleanEffect(\clean_leslie, [\leslie, \lrate, \lsize]),
			GlobalCleanEffect(\clean_rms, [\rmsReplyRate, \rmsPeakLag]).alwaysRun_(true),
			GlobalCleanEffect(\clean_monitor).alwaysRun_(true),

		]
	}

	globalEffects_ { |array|
		globalEffects = array.collect { |x| x.numChannels = clean.numChannels }
	}

	doOnServerTree {
		// on node tree init:
		this.initNodeTree
	}

	cmdPeriod {
		cutGroups.clear
	}

	initNodeTree {
		server.makeBundle(nil, { // make sure they are in order
			server.sendMsg("/g_new", group, 0, 1); // make sure group exists
			globalEffects.reverseDo { |x|
				x.play(group, outBus, dryBus, globalEffectBus, auxIndex)
			}
		})
	}

	value { |event|
		CleanEvent(this, clean.modules, event).play
	}

	valuePairs { |pairs|
		this.value((latency: server.latency).putPairs(pairs));
	}

	outBus_ { |bus|
		outBus = bus;
		this.initNodeTree;
	}

	set { |...pairs|
		pairs.pairsDo { |key, val|
			defaultParentEvent.put(key, val)
		}
	}

	get { |key|
		^defaultParentEvent.at(key)
	}

	setGlobalEffects { |...pairs|
		var event = ().putPairs(pairs);
		globalEffects.do { |x| x.set(event) };
	}

	amp_ { |val|
		this.set(\amp, val)
	}

	amp {
		^this.get(\amp)
	}

	fadeTime_ { |val|
		this.set(\fadeTime, val)
	}

	fadeTime {
		^this.get(\fadeTime)
	}

	freeSynths {
		server.bind {
			server.sendMsg("/n_free", group);
			this.initNodeTree
		}
	}

	startSendRMS { |rmsReplyRate = 8, rmsPeakLag = 3|
		this.setGlobalEffects(\rmsReplyRate, rmsReplyRate, \rmsPeakLag, rmsPeakLag);
		this.initNodeTree; // for now, we need this. check later why.
	}

	stopSendRMS {
		this.setGlobalEffects(\rmsReplyRate, 0, \rmsPeakLag, 0);
		this.initNodeTree;
	}

	free {
		clean.closeNetworkConnection;
		ServerTree.remove(this, server);
		globalEffects.do(_.release);
		server.freePermNodeID(group);
		synthBus.free;
		globalEffectBus.free;
		cutGroups.clear;
	}

	getCutGroup { |id|
		var cutGroup = cutGroups.at(id);
		if(cutGroup.isNil) {
			cutGroup = server.nextNodeID;
			server.sendMsg("/g_new", cutGroup, 1, group);
			cutGroups.put(id, cutGroup);
		}
		^cutGroup
	}


	makeDefaultParentEvent {
		defaultParentEvent = Event.make {

			~cps = 1.0;
			~offset = 0.0;
			~begin = 0.0;
			~end = 1.0;
			~spd = 1.0;
			~pan = 0.5;
			~amp = 1.0;
			~cut = 0.0;
			~unit = \r;
			~n = 0; // sample number or note
			~octave = 5;
			~midinote = #{ ~note ? ~n + (~octave * 12) };
			~freq = #{ ~midinote.value.midicps };
			~delta = 1.0;

			~latency = 0.0;
			~lag = 0.0;
			~length = 1.0;
			~loop = 1.0;
			~dry = 0.0;
			~lock = 0; // if set to 1, syncs delay times with cps

			~amp = 0.4;
			~fadeTime = 0.001;


			// values from the clean bus
			~aux = this;
			~clean = clean;
			~out = synthBus;
			~dryBus = dryBus;
			~effectBus = globalEffectBus;
			~numChannels = clean.numChannels;
			~server = server;

			~notFound = {
				"no synth or sample named '%' could be found.".format(~s).postln;
			};

		}
	}


}
