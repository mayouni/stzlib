# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #290.

load "../../../stzBase.ring"


o1 = new stzList([ 1, 2, 3, "A":"C", "A":"C", 6, 7, "A":"C" ])
? o1.FindNthPrevious(2, "A":"C", :StartingAt = 7)
#--> 4

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.25 second(s) in Rin 1.20
