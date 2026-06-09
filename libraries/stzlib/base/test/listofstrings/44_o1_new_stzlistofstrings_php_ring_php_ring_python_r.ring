# Narrative
# --------
# o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
#
# Extracted from stzlistofstringstest.ring, block #44.
#ERR Error (R14) : Calling Method without definition: replaceinstringnthenthoccurrence

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])

o1.ReplaceInStringNTheNthOccurrence(2, 3, "ring", "♥" )
? o1.Content()
#--> [ "php", "ring php ring python ♥", "python" ]

pf()
