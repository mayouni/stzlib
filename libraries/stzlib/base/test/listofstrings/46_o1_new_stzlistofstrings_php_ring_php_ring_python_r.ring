# Narrative
# --------
# o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
#
# Extracted from stzlistofstringstest.ring, block #46.

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])

o1.ReplaceInStringNTheLastOccurrence(2, "ring", "♥" )
? o1.Content()
#--> [ "php", "ring php ring python ♥", "python" ]

pf()
