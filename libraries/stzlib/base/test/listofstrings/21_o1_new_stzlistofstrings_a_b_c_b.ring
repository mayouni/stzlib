# Narrative
# --------
# o1 = new stzListOfStrings([ "A", "b", "C", "B" ])
#
# Extracted from stzlistofstringstest.ring, block #21.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

? o1.FindAllCS("B", :CS = FALSE)
#--> [2, 4]

pf()
