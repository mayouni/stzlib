# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #425.

load "../../../stzBase.ring"


o1 = new stzList([ "A", "B", 1, "C", 2, 3, "D", 4, 5 ])
? o1 - These([ "A", "B", "C", "D" ])
#--> [ 1, 2, 3, 4, 5 ]

pf()
# Executed in almost 0 second(s).
