/*

SuperCollider implementation of Clean.

This object handles local effects.
These are relative to a server and a number of output channels.
It keeps a number of clean auxs (see below).

*/

SuperClean {

	classvar <>cuedBufferSize = 32768;

	var <numChannels, <server;
	var <soundLibrary;
	var <>auxs;
	var <>modules;
	var <>audioRoutingBusses;

	//var <port, <senderAddr, netResponders;
	var <>receiveAction, <>warnOutOfAux = true, <>maxLatency = 42, <>numRoutingBusses = 16;

	classvar <>default, <>maxSampleNumChannels = 2, <>postBadValues = false;

	*new { |numChannels = 2, server|
		^super.newCopyArgs(numChannels, server ? Server.default).init;
	}

	init {
		soundLibrary = CleanSoundLibrary(server, numChannels);
		modules = [];
		this.loadSynthDefs;
		this.initRoutingBusses;
	}

	start { |outBusses|
		if(auxs.notNil) { this.stop };
		this.makeAuxs(outBusses ? [0]);
	}

	stop {
		auxs.do(_.free);
		auxs = nil;
	}

	makeAuxs { |outBusses|
		var new,
            i0 = if(auxs.isNil) { 0 } { auxs.lastIndex };

		new = outBusses.asArray.collect { |bus, i|
            CleanAux(this, bus, i + i0);
        };

		auxs = auxs ++ new;
		^new.unbubble
	}

	initRoutingBusses {
		audioRoutingBusses = { Bus.audio(server, numChannels) }.dup(numRoutingBusses)
	}

	set { |...pairs|
		auxs.do(_.set(*pairs))
	}

	free {
		soundLibrary.free;
		audioRoutingBusses.do(_.free);
		this.stop;
	}

	/* analysis */

	startSendRMS { |rmsReplyRate = 20, rmsPeakLag = 3|
		auxs.do(_.startSendRMS(rmsReplyRate, rmsPeakLag))
	}

	stopSendRMS {
		auxs.do(_.stopSendRMS)
	}

	/* sound library */

	soundLibrary_ { |argSoundLibrary|
		if(argSoundLibrary.server !== server or: { argSoundLibrary.numChannels != numChannels }) {
			Error("The number of channels and the server of a sound library have to match.").throw
		};
		soundLibrary = argSoundLibrary;
	}


	cueSoundFileFolder { |folderPath, name, appendToExisting = false|
		soundLibrary.loadSoundFileFolder(folderPath, name, appendToExisting, false)
	}

	cueSoundFiles { |paths, appendToExisting = false, namingFunction|
		soundLibrary.loadSoundFiles(paths, appendToExisting, namingFunction, false)
	}

	csf { |paths, appendToExisting = false, namingFunction|
		soundLibrary.loadSoundFiles(paths, appendToExisting, namingFunction, false)
	}

	cueSoundFile { |path, name, appendToExisting = false|
		soundLibrary.loadSoundFile(path, name, appendToExisting, false)
	}


	loadOnly { |names, path, appendToExisting = false|
		soundLibrary.loadOnly(names, path, appendToExisting)
	}

	loadSoundFileFolder { |folderPath, name, appendToExisting = false|
		soundLibrary.loadSoundFileFolder(folderPath, name, appendToExisting)
	}

	loadSoundFiles { |paths, appendToExisting = false, namingFunction|
		soundLibrary.loadSoundFiles(paths, appendToExisting, namingFunction)
	}

	lsf { |paths, appendToExisting = false, namingFunction|
		soundLibrary.loadSoundFiles(paths, appendToExisting, namingFunction)
	}

	loadSoundFile { |path, name, appendToExisting = false|
		soundLibrary.loadSoundFile(path, name, appendToExisting)
	}


	freeAllSoundFiles {
		soundLibrary.freeAllSoundFiles
	}

	freeSoundFiles { |names|
		soundLibrary.freeSoundFiles(names)
	}

	postSampleInfo {
		soundLibrary.postSampleInfo
	}

	verbose_ { |bool|
		soundLibrary.verbose_(bool)
	}

	verbose {
		^soundLibrary.verbose
	}

	buffers { ^soundLibrary.buffers }
	fileExtensions { ^soundLibrary.fileExtensions }
	fileExtensions_ { |list| ^soundLibrary.fileExtensions_(list) }

	/* modules */

	addModule { |name, func, test|
		var index, module;
		name = name.asSymbol;
		// the order of modules determines the order of synths
		// when replacing a module, we don't change the order
		module = CleanModule(name, func, test);
		index = modules.indexOfEqual(module);
		if(index.isNil) { modules = modules.add(module) } { modules.put(index, module) };
	}

	removeModule { |name|
		modules.removeAllSuchThat { |x| x.name == name }
	}

	getModule { |name|
		^modules.detect { |x| x.name == name }
	}

	clearModules {
		modules = [];
	}

	addFilterModule { |synthName, synthFunc, test|
		var instrument = synthName ++ numChannels;
		SynthDef(instrument, synthFunc).add;
		this.addModule(synthName, { |cleanEvent| cleanEvent.sendSynth(instrument) }, test);
	}

	orderModules { |names| // names provide some partial order
		var allNames = modules.collect { |x| x.name };
		var first = names.removeAt(0);
		var rest = difference(allNames, names);
		var firstIndex = rest.indexOf(first) ? -1 + 1;
		names = rest.insert(firstIndex, names).flatten;
		"new module order: %".format(names).postln;
		modules = names.collect { |x| this.getModule(x) }.reject { |x| x.isNil }
	}

	// SynthDefs are signal processing graph definitions.
	// This is also where the modules are added.

	loadSynthDefs { |path|
		var filePaths;
		path = path ?? { "../synths".resolveRelative };
		filePaths = pathMatch(standardizePath(path +/+ "*"));
		filePaths.do { |filepath|
			if(filepath.splitext.last == "scd") {
				(clean:this).use { filepath.load }; "loading synthdefs in %\n".postf(filepath)
			}
		}
	}
}

