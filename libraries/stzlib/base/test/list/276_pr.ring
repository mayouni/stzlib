# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #276.

load "../../stzBase.ring"


o1 = new stzList([ "1", "2", "♥", "4", "♥", "6", "7" ])

? o1.FindPrevious("♥", :StartingAt = 5)
#--> 3

? o1.FindNthPrevious(2, "♥", :StartingAt = 6)
#--> 5

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
