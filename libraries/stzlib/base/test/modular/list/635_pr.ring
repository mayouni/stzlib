# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #635.

load "../../../stzBase.ring"


o1 = new stzList([ "a", "b", "b", "b", "c" ])
o1.RemoveItemsAtPositions([2,3,4])
? o1.Content()
#--> [ "a", "c" ]

pf()
# Executed in almost 0 second(s).
