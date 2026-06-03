# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #591.
#ERR Error (R14) : Calling Method without definition: containsno

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])

? o1.ContainsNo("v")
#--> TRUE

? o1.ContainsNoObjects()
#--> TRUE

pf()
# Executed in almost 0 second(s).
