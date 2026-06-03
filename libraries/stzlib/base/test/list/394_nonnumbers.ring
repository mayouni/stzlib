# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #394.
#ERR Error (R14) : Calling Method without definition: nonnumbers

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1 - These( o1.NonNumbers() )
#-->  [ 1, 2, 3, 4, 5 ]

pf()
# Executed in almost 0 second(s).
