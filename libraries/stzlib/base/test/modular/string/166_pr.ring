# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #166.

load "../../../stzBase.ring"


o1 = new stzString("<<hi!>>..<<--♥♥♥--♥♥♥-->>..<<hi!>>")

? @@NL( o1.BoundedByZZ([ "<<", ">>" ]) ) + NL
#--> [	[ "hi!", [3, 5] ],
#	[ "--♥♥♥--♥♥♥--", [ 12, 23 ] ],
#	[ "hi!", [ 30, 32 ] ]
# ]

? @@NL( o1.BoundedByUZZ([ "<<", ">>" ]) )
#--> [
#	[ "hi!", [ [ 3, 5 ], [ 30, 32 ] ] ],
#	[ "--♥♥♥--♥♥♥--", [ [ 12, 23 ] ] ]
# ]

pf()
# Executed in 0.02 second(s) in Ring 1.22
# Executed in 0.20 second(s) in Ring 1.17
