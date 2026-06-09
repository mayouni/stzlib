# Narrative
# --------
# o1 = new stzListOfStrings([ "A", "b", "C", "B" ])
#
# Extracted from stzlistofstringstest.ring, block #21.
#ERR Error (R14) : Calling Method without definition: findallcs

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "A", "b", "C", "B" ])

? o1.FindAllCS("B", :CS = FALSE)
#--> [2, 4]

pf()
