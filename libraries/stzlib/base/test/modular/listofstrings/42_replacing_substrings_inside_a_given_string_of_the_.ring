# Narrative
# --------
# REPLACING SUBSTRINGS INSIDE A GIVEN STRING OF THE LIST
#
# Extracted from stzlistofstringstest.ring, block #42.

load "../../../stzBase.ring"


o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])

o1.ReplaceInStringN(2, "ring", :With = "♥")
? o1.Content()
#--> [ "php", "♥ php ♥ python ♥", "python" ]
