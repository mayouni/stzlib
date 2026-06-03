# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #707.

load "../../stzBase.ring"


o1 = new stzString("__b和平س__a_ووو")
? @@NL( o1.PartsUsingZZ(' StzCharQ(This[@i]).Script() ' ) )
#-->
# [
#	[ "__", [ 1, 2 ] ],
#	[ "b", [ 3, 3 ] ],
#	[ "和平", [ 4, 5 ] ],
#o	[ "س", [ 6, 6 ] ],
#	[ "__", [ 7, 8 ] ],
#	[ "a", [ 9, 9 ] ],
#	[ "_", [ 10, 10 ] ],
#o	[ "ووو", [ 11, 13 ] ]
# ]

pf()
# Executed in 0.09 second(s) in Ring 1.22
# Executed in 0.12 second(s) in Ring 1.18
