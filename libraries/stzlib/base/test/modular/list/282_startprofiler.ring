# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #282.

load "../../../stzBase.ring"

#                             3             6
o1 = new stzList([ "_", "_", "♥", "_", "_", "♥", "_" ])

? o1.FindFirst("♥")
#--> 3

? o1.FindLast("♥")
#--> 6

? o1.FindNext("♥", :StartingAt = 3)
#--> 6

? o1.FindPrevious("♥", :StartingAt = 6)
#--> 3

? o1.FindNthNext(1, "♥", :StartingAt = 6)
#--> 0

? o1.FindNthNext(1, "♥", :StartingAt = 5)
#--> 6

? o1.FindNthPrevious(2, "♥", :StartingAt = 7)
#--> 3

StopProfiler()
# Executed in 0.02 second(s) in Ring 1.22
