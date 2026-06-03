# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #623.
#ERR Error (R14) : Calling Method without definition: ismadeof

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "c", "a", "a", "b", "c" ])

? o1.IsMadeOf([ "a", "b", "c" ])
#--> TRUE

? o1.IsMadeOfSome([ "a", "b", "c", "x", "z" ])
#--> TRUE

pf()
# Executed in 0.02 second(s).
