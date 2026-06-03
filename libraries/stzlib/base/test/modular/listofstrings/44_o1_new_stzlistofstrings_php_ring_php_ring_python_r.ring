# Narrative
# --------
# o1 = new stzListOfStrings([ "php", "ring php ring python ring", "python" ])
#
# Extracted from stzlistofstringstest.ring, block #44.

load "../../../stzBase.ring"

o1.ReplaceInStringNTheNthOccurrence(2, 3, "ring", "♥" )
? o1.Content()
#--> [ "php", "ring php ring python ♥", "python" ]
