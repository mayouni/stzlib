# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #648.
#ERR Error (R14) : Calling Method without definition: allitemsareequalto

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 1, 1 ])
? o1.AllItemsAreEqualTo(1)

pf()
# Executed in almost 0 second(s).
