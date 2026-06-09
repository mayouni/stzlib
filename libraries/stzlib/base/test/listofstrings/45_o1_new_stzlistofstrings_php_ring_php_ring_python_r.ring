# Narrative
# --------
# o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
#
# Extracted from stzlistofstringstest.ring, block #45.
#ERR Error (R14) : Calling Method without definition: replaceinstringnthefirstoccurrence

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])

o1.ReplaceInStringNTheFirstOccurrence(2, "ring", "♥" )
? o1.Content()
#--> [ "php", "♥ php ring python ring", "python" ]

pf()
