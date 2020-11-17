CleanEvent {

	var <aux, <modules, <event;
	var server;

	*new { |aux, modules, event|
		^super.newCopyArgs(aux, modules, event)
	}

	play {
		event.parent = aux.defaultParentEvent;
		event.use {
			// s and n stand for synth/sample and note/number
			~s ?? { this.splitName };
			// unless aux wide diversion returns something, we proceed
			~diversion.(this) ?? {
				this.mergeSoundEvent;
				server = ~server.value; // as server is used a lot, make lookup more efficient
				this.orderTimeSpan;
				this.calcTimeSpan; // ~sustain is called here
				this.finaliseParameters;
				// unless event diversion returns something, we proceed
				~play.(this) ?? {
					if(~sustain >= aux.minSustain) { this.playSynths }; // otherwise drop it.
				}
			}
		}
	}

	splitName {
		var s, num;
		#s, num = ~sound.asString.split($:);
		~s = s.asSymbol;
		~num = if(num.notNil) { num.asFloat } { 0.0 };
	}

	mergeSoundEvent {
		var soundEvent = aux.clean.soundLibrary.getEvent(~s, ~num);
		if(soundEvent.isNil) {
			// only call ~notFound if no ~diversion is given that anyhow redirects control
			if(~diversion.isNil) { ~notFound.value }
		} {
			// the stored sound event becomes the environment's proto slot, which partly can override its parent
			currentEnvironment.proto = soundEvent
		}
	}

	orderTimeSpan {
		var temp;
		if(~end >= ~bgn) {
			if(~spd < 0) { temp = ~end; ~end = ~bgn; ~bgn = temp };
		} {
			// backwards
			~spd = ~spd.neg;
		};
		~length = absdif(~end, ~bgn);
	}

	calcTimeSpan {

		var sustain, unitDuration;
		var spd = ~spd.value;
		var lop = ~lop.value;
		var accelerate = ~accelerate.value;
		var avgspd, endspd;
		var useUnit;

		~freq = ~freq.value;
		unitDuration = ~unitDuration.value;
		useUnit = unitDuration.notNil;


		if (~unit == \c) {
			spd = spd * ~cps * if(useUnit) { unitDuration  } { 1.0 }
		};

		if(accelerate.isNil) {
			endspd = spd;
			avgspd = spd.abs;
		} {
			endspd = spd * (1.0 + accelerate);
			avgspd = spd.abs + endspd.abs * 0.5;
		};

		if(useUnit) {
			if(~unit == \rate) { ~unit = \r }; // API adaption to tidal output
			switch(~unit,
				\r, {
					unitDuration = unitDuration * ~length / avgspd;
				},
				\c, {
					unitDuration = unitDuration * ~length / avgspd;
				},
				\s, {
					unitDuration = ~length;
				},
				{ Error("this unit ('%') is not defined".format(~unit)).throw };
			)
		};

		sustain = ~sustain.value ?? {
			if(~legato.notNil) {
				~delta * ~legato.value
			} {
				unitDuration = unitDuration ? ~delta;
				lop !? { unitDuration = unitDuration * lop.abs };
			}
		};

		// end samples if sustain exceeds buffer duration
		// for every buffer, unitDuration is (and should be) defined.
		~buffer !? { sustain = min(unitDuration, sustain) };

		~fadeTime = min(~fadeTime.value, sustain * 0.19098);
		~fadeInTime = if(~bgn != 0) { ~fadeTime } { 0.0 };
		~sustain = sustain - (~fadeTime + ~fadeInTime);
		~spd = spd;
		~endspd = endspd;

	}

	finaliseParameters {
		~amp = pow(~amp.value, 1) * ~amp.value;
		~channel !? { ~pan = ~pan.value + (~channel.value / ~numChannels) };
		~pan = ~pan * 2 - 1; // convert unipolar (0..1) range into bipolar one (-1...1)
		~delayAmp = ~dla ? 0.0; // below is how you would rename parameter names to anything you want
		~delaytime = ~dlt ? 0.0;
		~delayfeedback = ~dlf ? 0.0;
		~bandf = ~bpf ? 0.0;
		~bandq = ~bpq ? 0.0;


		~latency = ~latency + ~lag.value + (~offset.value * ~spd.value); // don't accidentally change this tho
	}

	getMsgFunc { |instrument|
		var desc = SynthDescLib.global.at(instrument.asSymbol);
		^if(desc.notNil) { desc.msgFunc } { ~msgFunc }
	}

	sendSynth { |instrument, args|
		var group = ~synthGroup;
		args = args ?? { this.getMsgFunc(instrument).valueEnvir };
		args.asControlInput.flop.do { |each|
			server.sendMsg(\s_new,
				instrument,
				-1, // no id
				1, // add action: addToTail
				group, // send to group
				*each.asOSCArgArray // append all other args
			)
		}
	}

	sendGateSynth {
		server.sendMsg(\s_new,
			"clean_gate" ++ ~numChannels,
			-1, // no id
			1, // add action: addToTail
			~synthGroup, // send to group
			*[
				in: aux.synthBus.index, // read from synth bus, which is reused
				out: aux.dryBus.index, // write to aux dry bus
				amp: ~amp,
				sample: ~hash, // required for the cutgroup mechanism
				sustain: ~sustain, // after sustain, free all synths and group
				fadeInTime: ~fadeInTime, // fade in
				fadeTime: ~fadeTime // fade out
			]
		)
	}

	prepareSynthGroup { |outerGroup|
		~synthGroup = server.nextNodeID;
		server.sendMsg(\g_new, ~synthGroup, 1, outerGroup ? aux.group);
	}

	playSynths {
		var cutGroup;
		~cut = ~cut.value;
		if(~cut != 0) {
			cutGroup = aux.getCutGroup(~cut);
			~hash ?? { ~hash = ~sound.identityHash }; // just to be safe
		};

		server.makeBundle(~latency, { // use this to build a bundle

			aux.globalEffects.do { |x| x.set(currentEnvironment) };

			if(cutGroup.notNil) {
				server.sendMsg(\n_set, cutGroup, \gateSample, ~hash, \cutAll, if(~cut > 0) { 1 } { 0 });
			};

			this.prepareSynthGroup(cutGroup);
			modules.do(_.value(this));
			this.sendGateSynth; // this one needs to be last

		});

	}


}

