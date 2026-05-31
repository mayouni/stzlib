# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #223.

load "../../../stzBase.ring"


o1 = new stzList([ "_", "A", "_", "B", "C" ])
? o1.FindNthOccurrence(2, "_")
#--> 3

StopProfiler()
# Executed in 0.01 second(s) in Ring 1.21
