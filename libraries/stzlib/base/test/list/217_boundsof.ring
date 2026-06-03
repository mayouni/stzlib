# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #217.
#ERR Error (R14) : Calling Method without definition: boundsof

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, "*", 4, 5, 6, "*", 8, 9 ])

? @@NL( o1.BoundsOf("*", :UpToNItems = 2) ) + NL
#--> [
#	[ [ 1, 2 ], [ 4, 5 ] ],
#	[ [ 5, 6 ], [ 8, 9 ] ]
# ]

? @@NL( o1.BoundsOf("*", :UpToNItems = 3) )
#--> [
#	[ [ ], [ 4, 5, 6 ] ],
#	[ [ 4, 5, 6 ], [ ] ]
# ]

StopProfiler()

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.20
