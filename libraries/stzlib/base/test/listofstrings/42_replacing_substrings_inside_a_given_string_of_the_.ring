# Narrative
# --------
# REPLACING SUBSTRINGS INSIDE A GIVEN STRING OF THE LIST
#
# Extracted from stzlistofstringstest.ring, block #42.
#ERR Error (R11) : Error in class name, class not found: stzlistofstrings

load "../../stzBase.ring"

pr()

o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])

o1.ReplaceInStringN(2, "ring", :With = "♥")
? o1.Content()
#--> [ "php", "♥ php ♥ python ♥", "python" ]

pf()
