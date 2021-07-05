// Make an alias for a sample name.

(
~makeAlias = { | ...pairs |
	pairs.pairsDo { |from, to|
		var val = ~clean.soundLibrary.buffers[from];

		if(val.isNil) { warn("no such sample " ++ from ) } {
			if(~clean.soundLibrary.buffers[to].notNil) {
				warn("name already exists " ++ to )
			} {
				val.do { |buf|
					~clean.soundLibrary.addBuffer(to, buf, true)
				};
				postln("linked" ++ to ++ " -> " ++ from);
			}
		}
	};
};
)

~makeAlias.(\mmd, \m);

// For many:

~makeAlias.(\mmd, \m, \rnb, \rhythmnblues);
