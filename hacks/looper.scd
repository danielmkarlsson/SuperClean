/*
foolop is inspired by chunk-recorder.scd
This loper records from SoundIn and writes/replaces buffers directly to the SuperClean soundLibrary.

Copyright (C) 2019  Michael Hauck (f00b455)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

How to use in Tidal:

-- record and replace round robin
d1 $ sound "foolopRec"

-- stop recording and replacing
d1 $ silence

-- play recorded lop 3 (bufnamePrefix++counter)
d5 $ sound "foolop3" # gain "0.7"

-- reset buffers.
once $ sound "foolopReset"

*/
(
var functions = ();  // make a dictionary of functions
var recSynth, recBufs, counter = 0, recording = false;
var whichOrbit = ~clean.orbits[0];
var maxTime = 24; // allow a maximum of four seconds, adjust to your needs
var lat = s.latency + 0.02; // finetune
var numBuffers = 8; // number of buffers
var bufnamePrefix = "foolop"; // soundname prefix
var soundIn = Array.with(0);

~recBufs.do(_.free); // free them if they are left over (this is why we keep it in the environment variable)
~recBufs = recBufs = { Buffer.alloc(~clean.server, ~clean.server.sampleRate * maxTime, soundIn.size) } ! numBuffers;

// recorder writes audio from SoundIn to a bufnum
SynthDef(\fooRecord, { |bufnum|
    var in = SoundIn.ar(soundIn) * EnvGen.ar(Env.linen(0.003, 23, 0.003, 1, \sine), doneAction: 0);
    RecordBuf.ar(in, bufnum, lop:0, doneAction:2);
}).add;

// start recording round robin to buffers
functions[\foolopRec] = {
    if(recording) { functions[\foolopAdd].value };
    counter = counter + 1;
    if(counter > recBufs.lastIndex, {counter = 0});
    ~server.makeBundle(lat, {
    recSynth = Synth(\fooRecord, [bufnum: (recBufs @ counter)], ~server);
    recording = true;
    })
};
// add new buffer and free synth
functions[\foolopAdd] = {
    var name = bufnamePrefix ++ counter.asString;
    if(recording) {
    ~server.makeBundle(lat, {
    ~clean.soundLibrary.addBuffer(name, (recBufs @@ counter), false );
    recSynth.free;
    recording = false;
    })
    }
};
// reset all buffers
functions[\foolopReset] = {
    "reset".postln;
    ~recBufs.do(_.free);
    ~recBufs = recBufs = { Buffer.alloc(~clean.server, ~clean.server.sampleRate * maxTime, soundIn.size) } ! numBuffers;
    for(0,numBuffers-1, { |i|  ~clean.soundLibrary.addBuffer(bufnamePrefix++i, (recBufs @@ i), false )});
    counter = 0;
    recording = false;
};

// add these functions to the clean soundLibrary
functions.keysValuesDo{ |key, func|  ~clean.soundLibrary.addSynth( key, (play: func)) };

)
