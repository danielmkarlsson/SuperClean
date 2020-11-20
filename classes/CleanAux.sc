/*

An aux can be used as a separate audio output for when you want to do multichannel output,
or when you want to apply delay and or reverb to something. It is possible to have a part
of what you are hearing dry, and another part of what you are hearing wet. You can set up
auxs in the startup.scd file. Look for this line:

~cln.start(57120, [0,2,4,6]);

The above line gives you 8 outputs.
Another way to set your auxs would be to use them as sends to different effects:

~cln.start(57120, [0,0,0]);

The above line sets up three auxs and routes all of them to the first two audio outputs.
This way you could have one aux dry, one with reverb on it and the last on with dealy on it.
It is also possible to use both delay and reverb on the same aux.

*/

CleanAux {

	var <cln,  <outBus, <auxIndex;
	var <server;
	var <synthBus, <globalEffectBus, <dryBus;
	var <group, <globalEffects, <cutGroups;
	var <>minSustain;


	var <>defaultParentEvent;

	*new { |cln, outBus, auxIndex = 0|
		^super.newCopyArgs(cln, outBus, auxIndex).init
	}

	init {
		server = cln.server;
		if(server.serverRunning.not) {
			Error("SuperColldier server '%' not running. Couldn't start CleanAux".format(server.name)).warn;
			^this
		};
		group = server.nextPermNodeID;
		cutGroups = IdentityDictionary.new;
		synthBus = Bus.audio(server, cln.numChannels);
		dryBus = Bus.audio(server, cln.numChannels);
		globalEffectBus = Bus.audio(server, cln.numChannels);
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
			GlobalCleanEffect(\clean_reverb, [\rev, \rin, \dry]),
			//GlobalCleanEffect(\clean_gve, [\roomsize, \revtime, \damping, \inputbw, \spread, \drylevel, \earlyreflevel, \taillevel, \darken]),
			GlobalCleanEffect(\clean_leslie, [\leslie, \lrate, \lsize]),
			GlobalCleanEffect(\clean_rms, [\rmsReplyRate, \rmsPeakLag]).alwaysRun_(true),
			GlobalCleanEffect(\clean_monitor).alwaysRun_(true),

		]
	}

	globalEffects_ { |array|
		globalEffects = array.collect { |x| x.numChannels = cln.numChannels }
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
		CleanEvent(this, cln.modules, event).play
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
		cln.closeNetworkConnection;
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
			~bgn = 0.0;
			~end = 1.0;
			~spd = 1.0;
			~pan = 0.5;
			~amp = 1.0;
			~cut = 0.0;
			~num = 0; // sample number or note
			~unit = \r;
			~offset = 0.0;
			~octave = 5;
			~midinote = #{ ~note ? ~num + (~octave * 12) };
			~freq = #{ ~midinote.value.midicps };
			~delta = 1.0;

			~latency = 0.0;
			~lag = 0.0;
			~length = 1.0;
			~lop = 1.0;
			~dry = 0.0;
			~lock = 0; // if set to 1, syncs delay times with cps

			~amp = 0.4;
			~fadeTime = 0.001;


			// values from the clean bus
			~aux = this;
			~cln = cln;
			~out = synthBus;
			~dryBus = dryBus;
			~effectBus = globalEffectBus;
			~numChannels = cln.numChannels;
			~server = server;

			~notFound = {
				"no synth or sample named '%' could be found.".format(~snd).postln;
			};

		}
	}


}
