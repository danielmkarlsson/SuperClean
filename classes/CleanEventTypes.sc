/*

This class adds event types to the global event library. They can be played from sclang.

*/

CleanEventTypes {
	classvar <midiEvent;

	*initClass {
	    var ccKeys = (0..127).collect {|i| ("cc" ++ i).asSymbol };
	    var sendCC = {|midiout, latency=0, chan, ccNum, ccVal|
            if (latency == 0.0) {
                midiout.control(chan, ccNum, ccVal)
            } {
                thisThread.clock.sched(latency, {
                    midiout.control(chan, ccNum, ccVal)
                });
            }
        };

        // allows to play events in superclean from sclang

		Event.addEventType(\cln, {
			var keys, values;
			var clean = ~clean ? SuperClean.default;
			var midiout, ccn, ccv, chan;
			if(clean.isNil) {
				Error("clean event: no clean instance found.\n\n// You could try:\nSuperClean.default = ~clean;").throw;
			};
			~delta = ~delta ?? { ~stretch.value * ~dur.value };
			~latency = ~latency ?? { clean.server.latency };

            midiout = ~mid;
            if (midiout.notNil) {
                chan = ~chan ? 0;
                if (~ccn.notNil and:{~ccv.notNil}) {
                    ccn = ~ccn;
                    ccv = ~ccv;
                    sendCC.(midiout, ~latency, chan, ccn, ccv);
                };
                ccKeys.do {|key, i|
                    var value = currentEnvironment.at(key);
                    if (value.notNil) {
                        sendCC.(midiout, ~latency, chan, i, value);
                    };
                };
            };

			if(~num.isArray) {
				keys = currentEnvironment.keys.asArray;
				values = keys.collect(_.envirGet).flop;
				values.do { |each|
					var e = Event(parent: currentEnvironment);
					keys.do { |key, i| e.put(key, each.at(i)) };
					clean.auxs.wrapAt(e[\aux] ? 0).value(e)
				}
			} {
				clean.auxs.wrapAt(~aux ? 0).value(currentEnvironment);
			}
		});

		// corrected event type, fixing a few things from the standard \midi event type

		midiEvent = (
			play: #{

				var freq, lag, sustain, func;
				var args, midiout, hasGate, midicmd, latency;
				midicmd = ~midicmd;

				if(midicmd.isNil) {
					if(~ccn.notNil) { midicmd = \control; ~ctlNum = ~ccn };
					if(~ccv.notNil) { midicmd = \control; ~control = ~ccv };
					if(~progNum.notNil) { midicmd = \program };
					if(~polyTouch.notNil) { midicmd = \polyTouch };
					if(~midibend.notNil) { midicmd = \bend; ~val = ~midibend; };
					if(~miditouch.notNil) { midicmd = \touch; ~val = ~miditouch; };
					if(midicmd.isNil) { midicmd = \noteOn }; // if still nil
				};


				freq = ~freq.value;

				~amp = ~amp.value;
				~midinote = (freq.cpsmidi).round(1).asInteger;
				lag = ~lag + (~latency ? 0);
				sustain = ~sustain = ~sustain.value;
				midiout = ~m.value;
				if(~uid.notNil and: { midiout.notNil }) {
					~uid = midiout.uid    // mainly for sysex cmd
				};
				hasGate = ~hasGate ? true; // TODO

				~ctlNum = ~ctlNum ? 0;
				~chan = ~midichan ? 0;

				func = Event.default[\midiEventFunctions][midicmd];
				args = func.valueEnvir.asCollection;

				latency = lag; // for now.

				if(midiout.notNil) {

					if(latency == 0.0) {
						midiout.performList(midicmd, args)
					} {
						thisThread.clock.sched(latency, {
							midiout.performList(midicmd, args);
						})
					};
					if(hasGate and: { midicmd === \noteOn }) {
						thisThread.clock.sched(sustain + latency, {
							midiout.noteOff(*args)
						});
					}
				} {
					"midi device is nil, cmd: '%' args: %"
					.format(midicmd, [func.argNames, args].flop.flat.join(" "))
					.postln
				};

				true // always return something != nil to end processing in CleanEvent
			}
		)
	}
}