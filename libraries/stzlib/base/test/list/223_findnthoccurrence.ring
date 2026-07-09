# Narrative
# --------

#
# Extracted from stzlisttest.ring, block #223.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "A", "_", "B", "C" ])
? o1.FindNthOccurrence(2, "_")
#--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.27
# Executed in 0.01 second(s) in Ring 1.21
