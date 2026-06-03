# Narrative
# --------
# o1 = new stzListOfStrings([ "php", "php ring python", "python" ])
#
# Extracted from stzlistofstringstest.ring, block #43.
#ERR Error (R24) : Using uninitialized variable: o1

load "../../stzBase.ring"

pr()

o1.ReplaceSubStringAtPosition([2, 5], "ring", "♥" )
? o1.Content()
#--> [ "php", "php ♥ python", "python" ]

pf()
