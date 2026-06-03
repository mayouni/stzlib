# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #646.

load "../../stzBase.ring"


o1 = new stzList([ "A", "B", "C", "D", "E", "F" ])
? @@( o1.WalkUntilItem("D") )
#--> [ 1, 2, 3, 4 ]

pf()
# Executed in 0.01 second(s) in Ring 1.22
