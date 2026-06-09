# Narrative
# --------
# o1 = new stzListOfStrings([ "A", "b", "C", "B" ])
#
# Extracted from stzlistofstringstest.ring, block #22.
#ERR Error (R14) : Calling Method without definition: replacestringcs

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "A", "b", "C", "B" ])

o1.ReplaceStringCS("B", "_", :CS = FALSE)
? o1.Content() #--> [ "A", "_", "C", "_" ]

pf()
