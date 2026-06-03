# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #173.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8, 9 ])
? o1.FindNext("*", :StartingAt = 4)
#--> 7

pf()
# Executed in 0.05 second(s)
