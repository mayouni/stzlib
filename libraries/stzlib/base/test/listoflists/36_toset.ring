# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #36.
#ERR Error (R14) : Calling Method without definition: toset

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "ab", "b", 1:3, "a", "ab", "abc", "b", "bc", 1:3, "c" ])
? @@( o1.ToSet() )
#--> [ "a", "ab", "b", [ 1, 2, 3 ], "abc", "bc", "c" ]

pf()
# Executed in 0.17 second(s)
