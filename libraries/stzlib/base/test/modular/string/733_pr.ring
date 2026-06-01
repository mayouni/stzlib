# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #733.

load "../../../stzBase.ring"


o1 = new stzString("Hanine حنين is a nice جميلة وعمرها 7 years-old سنوات girl!")

? @@NL(o1.PartsUsingZZ( 'StzCharQ(This[@i]).CharCase()' ))

#--> [
#	[ "H", [ 1, 1 ] ],
#	[ "anine", [ 2, 6 ] ],
#o	[ " حنين ", [ 7, 12 ] ],
#	[ "is", [ 13, 14 ] ],
#	[ " ", [ 15, 15 ] ],
#	[ "a", [ 16, 16 ] ],
#	[ " ", [ 17, 17 ] ],
#	[ "nice", [ 18, 21 ] ],
#o	[ " جميلة وعمرها 7 ", [ 22, 37 ] ],
#	[ "years", [ 38, 42 ] ],
#	[ "-", [ 43, 43 ] ],
#	[ "old", [ 44, 46 ] ],
#o	[ " سنوات ", [ 47, 53 ] ],
#	[ "girl", [ 54, 57 ] ],
#	[ "!", [ 58, 58 ] ]
# ]

pf()
# Executed in 0.35 second(s).
