/*

adding a post function

*/

(
~clean.addModule('post',
	{ |cleanEvent|
		"\n------------\n".post;
		cleanEvent.event.pairsDo { |key, val, i|
			"%: % ".format(key, val).post;
			if(i % 4 == 0) { "\n".post };
		}

});
)

// remove it again:
~clean.removeModule(\post);
