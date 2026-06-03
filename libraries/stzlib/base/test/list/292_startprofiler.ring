# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #292.

load "../../stzBase.ring"


o1 = new stzList([ 1, 2, "A":"C", 4, 5, "A":"C", 7, "A":"C"])
? o1.FindFirst("A":"C")
#--> 3
? o1.FindNth(2,"A":"C")
#--> 6
? o1.FindLast("A":"C")
#--> 8

StopProfiler()
# Executed in 0.02 second(s) in Ring 1.21
# Executed in 0.38 second(s) in Ring 1.19
