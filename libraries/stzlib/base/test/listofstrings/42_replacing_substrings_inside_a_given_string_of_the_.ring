# Narrative
# --------
# REPLACING SUBSTRINGS INSIDE A GIVEN STRING OF THE LIST
#
# Extracted from stzlistofstringstest.ring, block #42.
#ERR Error (R14) : Calling Method without definition: replaceinstringn

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])

o1.ReplaceInStringN(2, "ring", :With = "♥")
? o1.Content()
#--> [ "php", "♥ php ♥ python ♥", "python" ]

pf()
