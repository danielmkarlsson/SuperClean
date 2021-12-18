/*

CleanModules encapsulate two functions:
1) For testing for parameters (whether or not to start a synth at all).
2) Activated when the parameters are found in the message.

*/


CleanModule {
	var <name, <func, <test;

	*new { |name, func, test|
		^super.newCopyArgs(name, func, test ? true)
	}

	value { |aux|
		if(test.value, { func.value(aux) })
	}

	== { arg that;
		^this.compareObject(that, #[\name])
	}

	hash {
		^this.instVarHash(#[\name])
	}

	printOn { |stream|
		stream  << this.class.name << "(" <<< name << ")"
	}

	storeArgs {
		^[name, func, test]
	}
}
