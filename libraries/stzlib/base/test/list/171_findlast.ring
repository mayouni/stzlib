# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #171.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8, 9 ])
? o1.FindLast("*")
#--> 7

pf()
# Executed in 0.04 second(s)
