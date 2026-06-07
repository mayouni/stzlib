# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #293.

load "../../stzBase.ring"

pr()

o1 = new stzString(" so ftan   za ")
o1.Unspacify()
? o1.Content()
#--> "so ftan za"

pf()
# Executed in 0.01 second(s)
