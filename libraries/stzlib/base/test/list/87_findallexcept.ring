# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #87.
#ERR Error (R14) : Calling Method without definition: findallexcept

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", "A", "B", "C", "♥" ])
? o1.FindAllExcept([ "A", "B", "C" ]) # Or FindItemsOtherThan()
#--> [1, 5]

pf()
# Executed in 0.04 second(s)
