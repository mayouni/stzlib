# Narrative
# --------
# o1 = new stzListOfStrings(  [ "Tunis", "gatufsa", "tunis", "gabes", "tunis", "regueb", "tuta", "regueb" ])
#
# Extracted from stzlistofstringstest.ring, block #105.

load "../../stzBase.ring"

o1.SortInDescending()
? @@(o1.Content())
#--> [ "tuta", "tunis", "tunis", "regueb", "regueb", "gatufsa", "gabes", "Tunis" ]
