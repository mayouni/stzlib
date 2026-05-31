# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #176.

load "../../../stzBase.ring"


o1 = new stzList(1: 100_000)
? o1.IsListOfNumbers()
#--> TRUE

? o1.FindFirst(67_000)
#--> 67000

pf()
# Executed in 0.34 second(s) in Ring 1.22
# Executed in 0.54 in Ring 1.19
