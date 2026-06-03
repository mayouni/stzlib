# Narrative
# --------
# o1 = new stzListOfStrings([ "A", "b", "C", "B" ])
#
# Extracted from stzlistofstringstest.ring, block #22.

load "../../stzBase.ring"

o1.ReplaceStringCS("B", "_", :CS = FALSE)
? o1.Content() #--> [ "A", "_", "C", "_" ]
