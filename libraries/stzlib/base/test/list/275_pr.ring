# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #275.

load "../../stzBase.ring"


o1 = new stzString("12♥4♥67")

? o1.FindPrevious("♥", :StartingAt = 5)
#--> 3

? o1.FindNthPrevious(2, "♥", :StartingAt = 6)
#--> 3

pf()
# Executed in 0.01 second(s)
