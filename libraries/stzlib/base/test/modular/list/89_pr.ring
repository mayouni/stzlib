# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #89.

load "../../../stzBase.ring"


o1 = new stzList("A" : "E")
? o1.ItemsAtPositions([2, 3])
#--> [ "B", "C" ]

pf()
#--> Executed in 0.03 second(s)
