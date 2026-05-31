# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #300.

load "../../../stzBase.ring"


o1 = new stzList([0, 0, 1, 0, 1])
? o1.FindLast(0)
#--> 4

StopProfiler()
# Executed in almost 0 second(s).
