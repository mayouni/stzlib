# Narrative
# --------
# o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
#
# Extracted from stzlistofstringstest.ring, block #44.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

o1.ReplaceInStringNTheNthOccurrence(2, 3, "ring", "♥" )
? o1.Content()
#--> [ "php", "ring php ring python ♥", "python" ]

pf()
