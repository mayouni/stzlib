# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #572.

load "../../../stzBase.ring"


o1 = new stzList([ 5, 4, "tunis", 3, 7, "cairo" ])
o1.SortInAscending()
? o1.Content()
#--> [ 3, 4, 5, 7, "cairo", "tunis" ]

pf()
