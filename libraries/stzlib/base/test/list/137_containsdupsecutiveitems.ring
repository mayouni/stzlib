# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #137.
#ERR Error (R14) : Calling Method without definition: containsdupsecutiveitems

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C" ])
? o1.ContainsDupSecutiveItems()
#--> FALSE

pf()
# Executed in 0.01 second(s).
