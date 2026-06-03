# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #453.

load "../../stzBase.ring"


o1 = new stzList([ "A", "A", "A", "B", "B", "C" ])
? o1.FindNthCS(3, "A", FALSE)
#--> 3

pf()
# Executed in 0.01 second(s) in Ring 1.21
