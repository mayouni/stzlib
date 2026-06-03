# Narrative
# --------
# pr()
#
# Extracted from stzlistofliststest.ring, block #37.
#ERR Error (R14) : Calling Method without definition: toset

load "../../stzBase.ring"

pr()

? Q([ "a", "ab", "b", [ 1, 2, 3 ] ]).ToSet()
#--> [ "a", "ab", "b", [ 1, 2, 3 ] ]

pf()
#--> Executed in 0.06 second(s)
