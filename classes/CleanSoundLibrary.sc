/*

This library unifies access to buffers and synth events.

Valid fileExtensions are ["wav", "aif", "aiff", "aifc"].

*/

CleanSoundLibrary {

	var <server, <numChannels, <buffers, <bufferEvents, <synthEvents;
	var <>fileExtensions = #["wav", "aif", "aiff", "aifc"];
	var <>verbose = false;
	var <>defaultEvent;

	*new { |server, numChannels|
		^super.newCopyArgs(server, numChannels).init
	}

	init {
		buffers = IdentityDictionary.new;
		bufferEvents = IdentityDictionary.new;
		synthEvents = IdentityDictionary.new;
	}

	free {
		synthEvents.clear;
		this.freeAllSoundFiles;
	}

	addBuffer { |name, buffer, appendToExisting = false, cued = false|
		var event;
		if(buffer.isNil) { Error("tried to add Nil to buffer library").throw };
		if(synthEvents[name].notNil) {
			"a synth event with that name already exists: %\nSkipping...".format(name).warn;
			^this
		};
		name = name.asSymbol;
		if(appendToExisting.not and: { buffers[name].notNil }) {
			"\nreplacing '%' (%)\n".postf(name, buffers[name].size);
			this.freeSoundFiles(name);
		};
		event = if(cued) { this.makeEventForCuedBuffer(buffer) } { this.makeEventForBuffer(buffer) };
		buffers[name] = buffers[name].add(buffer);
		bufferEvents[name] = bufferEvents[name].add(event);
		if(verbose) { "new sample buffer named '%':\n%\n\n".postf(name, event) };
	}

	addSynth { |name, event, appendToExisting = false, useSynthDefSustain = false|
		if(bufferEvents[name].notNil) {
			"a sample buffer with that name already exists: %\nSkipping...".format(name).warn;
			^this
		};
		if(appendToExisting.not and: { synthEvents[name].notNil }) {
			"\nreplacing '%' (%)\n".postf(name, synthEvents[name].size);
			synthEvents[name] = nil;
		};
		if(event.isNil) { event = (instrument: name) };
		if(event[\hash].isNil) { event[\hash] = name.identityHash };
		if(useSynthDefSustain) { this.useSynthDefSustain(event) };
		synthEvents[name] = synthEvents[name].add(event);
		if(verbose) { "new synth named '%':\n%\n\n".postf(name, event) };
	}

	addMIDI { |name, device, event|
		var midiEvent = CleanEventTypes.midiEvent.copy.put(\midiout, device);
		if(event.notNil) { midiEvent.putAll(event) };
		this.addSynth(name, midiEvent)
	}

	useSynthDefSustain { |event|
		event.use {
			~unitDuration = {
				var synthDesc = SynthDescLib.at(~instrument.value);
				var sustainControl;
				if(synthDesc.notNil) {
					sustainControl = synthDesc.controlDict.at(\sustain);
					if(sustainControl.notNil) {
						sustainControl.defaultValue
					}
				}
			}
		}
	}

	freeSoundFiles { |names|
		names.asArray.do { |name|
			buffers.removeAt(name).asArray.do { |buf|
				if(this.findBuffer(buf).notNil) { buf.free } // don't free aliases
			};
			bufferEvents.removeAt(name);
		}
	}

	freeSynths { |names|
		names.asArray.do { |name|
			synthEvents.removeAt(name)
		}
	}

	set { |name, indices ... pairs|
		var allEvents = this.at(name);
		if(allEvents.isNil) {
			"set: no events found with this name: %\n".format(name).warn
		} {
			if(indices.notNil) { allEvents = allEvents.at(indices.asArray) };
			allEvents.do { |each|
				each.putPairs(pairs)
			}
		}
	}

	at { |name|
		^bufferEvents[name] ?? { synthEvents[name] }
	}

	freeAllSoundFiles {
		buffers.do { |x| x.asArray.do { |buf| buf.free } };
		buffers = IdentityDictionary.new;
		bufferEvents = IdentityDictionary.new;
	}

	/*

	file loading

	*/

	prGetSuperCleanPath {
		var path;
		path = Main.packages.asDict.at('SuperClean');
		if (path.isNil, {
			path = Main.packages.asDict.at('SuperClean-main');
			if (path.isNil, {
				"SuperClean:: The SuperClean root folder should be named either 'SuperClean' or 'SuperClean-main'".warn;
			})
		});
		^path
	}

	loadOnly { |names, path, appendToExisting = false|
		var defaultSamplePath = this.prGetSuperCleanPath +/+ "clean-samples";
		path = path ?? { defaultSamplePath };
		names.do { |name|
			this.loadSoundFileFolder(path +/+ name, name, appendToExisting)
		};
		//"\nfile reading complete\n\n".post;
	}

	loadSoundFiles { |paths, appendToExisting = false, namingFunction = (_.basename), allocate = true| // paths are folderPaths
		var folderPaths, memory;
		//var defaultSamplePath =  this.prGetSuperCleanPath +/+ "clean-samples" +/+ "mmd";
		var defaultSamplePath =  this.prGetSuperCleanPath +/+ "clean-samples/*"; // Will wildcard work on "other" os's?


		paths = paths ?? { defaultSamplePath };
		folderPaths = if(paths.isString) { paths.pathMatch } { paths.asArray };
		folderPaths = folderPaths.select(_.endsWith(Platform.pathSeparator.asString));
		if(folderPaths.isEmpty) {
			"no folders found in paths: '%'".format(paths).warn; ^this
		};
		memory = this.memoryFootprint;
		"\nloading % sample bank%:\n".postf(folderPaths.size, if(folderPaths.size > 1) { "snd" } { "" });
		folderPaths.do { |folderPath|
			this.loadSoundFileFolder(folderPath, namingFunction.(folderPath), appendToExisting, allocate)
		};
		"\nRequired % MB of memory.\n\n".format(
			this.memoryFootprint - memory div: 1e6
		).post;
	}

	loadSoundFileFolder { |folderPath, name, appendToExisting = false, allocate = true|
		var files;

		if(File.exists(folderPath).not) {
			"\ncouldn't load '%' files, path doesn't exist: %.".format(name, folderPath).postln;
			^this
		};

		files = pathMatch(folderPath.standardizePath +/+ "*"); // dependent on operating system

		if(files.notEmpty) {
			name = name.asSymbol;
			this.loadSoundFilePaths(files, name, appendToExisting, allocate);
			"% (%) ".postf(name, buffers[name].size);
		} {
			"empty sample folder: %\n".postf(folderPath)
		}

	}

	loadSoundFilePaths { |filePaths, name, appendToExisting = false, allocate = true|
		var buf;

		filePaths.do { |filepath|
			try {
				buf = this.readSoundFile(filepath, allocate: allocate);
				if(buf.notNil) {
					this.addBuffer(name, buf, appendToExisting, cued: allocate.not);
					appendToExisting = true; // append all others
				}
			}
		};

	}

	loadSoundFile { |path, name, appendToExisting = false, allocate = true|
		var buf = this.readSoundFile(path, allocate: allocate);
		if(buf.notNil) { this.addBuffer(name, buf, appendToExisting, cued: allocate.not) }
	}

	readSoundFile { |path, allocate = true|
		var fileExt = (path.splitext[1] ? "").toLower;
		if(fileExtensions.includesEqual(fileExt).not) {
			if(verbose) { "\nignored file: %\n".postf(path) };
			^nil
		}
		^Buffer.cleanReadWithInfo(server, path, allocate: allocate)
	}

	/* access */


	findBuffer { |buf|
		buffers.keysValuesDo { |key, val|
			var index = val.indexOf(buf);
			if(index.notNil) { ^[key, index] };
		};
		^nil
	}

	// ~snd = name, ~num = index
	getEvent { |name, index|
		// first look up buffers, then synths
		var allEvents = this.at(name);
		^if(allEvents.isNil) {
			if(SynthDescLib.at(name).notNil) {
				(instrument: name, hash: name.identityHash)
			} {
				if(defaultEvent.notNil) {
					(instrument: name, hash: name.identityHash).putAll(defaultEvent)
				}
			}
		} {
			allEvents.wrapAt(index.asInteger)
		}
	}

	makeEventForBuffer { |buffer|
		var baseFreq = 60.midicps;
		^(
			buffer: buffer.bufnum,
			instrument: this.instrumentForBuffer(buffer),
			bufNumFrames: buffer.numFrames,
			bufNumChannels: buffer.numChannels,
			unitDuration: { buffer.duration * baseFreq / ~freq.value },
			hash: buffer.identityHash,
			note: 0
		)
	}

	instrumentForBuffer { |buffer|
		^format("clean_sample_%_%", buffer.numChannels, this.numChannels).asSymbol
	}

	makeEventForCuedBuffer { |buffer|
		var baseFreq = 60.midicps;
		^(
			buffer: buffer.bufnum,
			instrument: this.instrumentForCuedBuffer(buffer),
			bufNumFrames: buffer.numFrames,
			bufNumChannels: buffer.numChannels,
			unitDuration: { buffer.duration * baseFreq / ~freq.value },
			hash: buffer.identityHash,
			disk: true,
			path: buffer.path
		)
	}

	instrumentForCuedBuffer { |buffer|
		^format("clean_sampledisk_%_%", buffer.numChannels, this.numChannels).asSymbol
	}

	openFolder { |name, index = 0|
		var buf, list;
		list = buffers.at(name);
		if(list.isNil) { "No buffer for this name: %".format(name).warn; ^this };
		buf = list.at(index);
		if(buf.isNil) { "No buffer at this index: %:%".format(name, index).warn; ^this };
		systemCmd("open" + buf.path.dirname)
	}

	/* copy  */

	shallowCopy {
		^super.shallowCopy.prCopyEvents
	}

	numChannels_ { |n|
		numChannels = n;
		bufferEvents = bufferEvents.collect { |list|
			list.do { |event|
				event[\instrument] = this.instrumentForBuffer(event[\buffer])
			}
		}
	}

	/* info */

	postSampleInfo {
		var keys = buffers.keys.asArray.sort;
		if(buffers.isEmpty) {
			"\nCurrently there are no samples loaded.".postln;
		} {
			"\nCurrently there are % sample banks in memory (% MB):\n\nName (number of variants), range of durations (memory)\n"
			.format(buffers.size, this.memoryFootprint div: 1e6).postln;
		};
		keys.do { |name|
			var count = 0;
			var all = buffers[name];
			"% (%)   % - % sec (% kB)%\n".postf(
				name,
				buffers[name].size,
				all.minItem { |x| x.duration }.duration.round(0.01),
				all.maxItem { |x| x.duration }.duration.round(0.01),
				bufferEvents[name].sum { |x|
					if(x['disk'].isNil) {
						x['bufNumFrames']
					} {
						count = count + 1;
						SuperClean.cuedBufferSize
					} * x['bufNumChannels'] * 4 // in bytes
				} div: 1e3,
				if(count > 0) {", % cued".format(count)} {""}
			)
		}
	}

	memoryFootprint {
		^bufferEvents.sum { |array|
			array.sum { |x|
				if(x['disk'].isNil) {
					x['bufNumFrames']
				} {
					SuperClean.cuedBufferSize
				} * x['bufNumChannels'] * 4 // in bytes
			}
		}
	}

	/* private implementation */

	prCopyEvents {
		bufferEvents = bufferEvents.copy;
		synthEvents = synthEvents.copy;
	}
}
