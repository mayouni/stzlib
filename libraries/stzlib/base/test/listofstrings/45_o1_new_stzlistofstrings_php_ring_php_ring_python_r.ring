# Narrative
# --------
# o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
#
# Extracted from stzlistofstringstest.ring, block #45.

load "../../stzBase.ring"

o1.ReplaceInStringNTheFirstOccurrence(2, "ring", "♥" )
? o1.Content()
#--> [ "php", "♥ php ring python ring", "python" ]
