# Narrative
# --------
# o1 = new stzListOfStrings([ "php", "php ring python", "python" ])
#
# Extracted from stzlistofstringstest.ring, block #43.
#ERR Error (R14) : Calling Method without definition: replacesubstringatposition

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "php", "php ring python", "python" ])

o1.ReplaceSubStringAtPosition([2, 5], "ring", "♥" )
? o1.Content()
#--> [ "php", "php ♥ python", "python" ]

pf()
