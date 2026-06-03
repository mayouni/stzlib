# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #431.
#ERR Error (R14) : Calling Method without definition: hassamecontentas

load "../../stzBase.ring"

pr()

? ListContains([ "q", "r", [ 2, 1 ] ], [ 2, 1 ])
#--> TRUE

? StzListQ([ "q", "r", [ 2, 1] ]).HasSameContentAs([ "r", [ 2, 1], "q" ])
#--> TRUE

? StzListQ([ "q", "r", [ 2, 1] ]).HasSameSortingOrderAs([ "r", [ 2, 1], "q" ])
#--> FALSE

? StzListQ([ "q", "r", [ 2, 1] ]).IsEqualTo([ "q", "r", [2, 1] ])
#--> TRUE

pf()
# Executed in 0.02 second(s).
