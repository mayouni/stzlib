# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #563.
#ERR Error (R14) : Calling Method without definition: removeoccurrences

load "../../stzBase.ring"

pr()

o1 = new stzList([ "a", "b", "a", "a", "c", "d", "a" ])
o1.RemoveOccurrences([ 4, 1, 3 ], "a")
? o1.Content()
#--> [ "b", "a", "c", "d" ]

pf()
# Executed in almost 0 second(s).
