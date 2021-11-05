/*

An aux can be used as a separate audio output for when you want to do multichannel output,
or when you want to apply delay, reverb or some other effect to different things. It is possible to
have a part of what you are hearing dry, and another part of what you are hearing wet. You can
set up auxs in the startup.scd file. Look for this line:

~clean.start([0,2,4,6]);

The above line gives you 8 outputs.
Another way to set your auxs would be to use them as sends to different effects:

~clean.start([0,0,0]);

The above line sets up three auxs and routes all of them to the first two audio outputs.
This way you could have one aux dry, one with reverb on it and the last one with delay on it.
It is also possible to use both delay and reverb on the same aux.

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
			GlobalCleanEffect(\clean_hal, [\hal, \rts, \bld, \edf, \ldf, \hhp, \hlp]),
			GlobalCleanEffect(\clean_delay, [\delaytime, \delayfeedback, \delaySend, \delayAmp, \lock, \cps]),
			GlobalCleanEffect(\clean_reverb, [\rev, \rin, \dry]),
			//GlobalCleanEffect(\clean_grainfb, [\grainfb]),
			GlobalCleanEffect(\clean_cav, [\cav, \cai, \cvt, \cvd, \cvl]),
			GlobalCleanEffect(\clean_mir, [\mir, \mii]),
			GlobalCleanEffect(\clean_tanh, [\tnh, \tng, \tnb, \tna]),
			//GlobalCleanEffect(\tap, [\tap, \drp]),
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
			~bgn = 0.0;
			~end = 1.0;
			~spd = 1.0;
			~pan = 0.5;
			~amp = 0.5;
			~cut = 0.0;
			~nhp = 20;
			~nlp = 20000;
			~unit = \r;
			~midinote = #{ ~note ? ~num + (~octave * 12) };
			~freq = #{
                var degree = ~degree;
                var scale = ~scale;
				var octave = ~octave;
				var harmonic = ~harmonic;
				var tuning = ~tuning;
				var mtranspose = ~mtranspose;
                var gtranspose = ~gtranspose;
				var ctranspose = ~ctranspose;
				var root = ~root;
				var stepsPerOctave = ~stepsPerOctave;
				var octaveRatio = ~octaveRatio;
				var num = ~num;
				var midinote = ~midinote;
				//var note = ~note;
				Event.default.use {
					~root = root;
                    ~degree = degree;
                    ~scale = scale;
					~octave = octave;
					~harmonic = harmonic;
					~tuning = tuning;
                    ~mtranspose = mtranspose;
					~gtranspose = gtranspose;
					~ctranspose = ctranspose;
					~stepsPerOctave = stepsPerOctave;
					~octaveRatio = octaveRatio;
					~num = num;
					~midinote = midinote;
					//~note = note;
					~freq.value;
                }
            };
			~root = 0.0;     // root of the scale
			~mtranspose = 0.0;
			~gtranspose = 0.0;
			~ctranspose = 0.0;
			~octave = 5.0;
			~degree = 0;
			~scale = #[0, 2, 4, 5, 7, 9, 11];  // diatonic major scale
			~stepsPerOctave = 12.0;
			~detuneFreq = 0.0;     // detune in Hertz
			~harmonic = 1.0;    // harmonic ratio
			~octaveRatio = 2.0;
			~num = 0; // sample number or note
			//~freq = #{ ~midinote.value.midicps };
			~delta = 1.0;
			~latency = 0.0;
			~lag = 0.0;
			~length = 1.0;
			~dry = 0.0;
			~lock = 0; // if set to 1, syncs delay times with cps
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
				"no synth or sample named '%' could be found.".format(~snd).postln;
			};
		}
	}
}
