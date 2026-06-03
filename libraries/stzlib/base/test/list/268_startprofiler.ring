# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #268.

load "../../stzBase.ring"

#                   1    2    3    4    5    6    7     8    9   10
o1 = new stzList([ "_", "_", "♥", "_", "_", "♥", "_" , "♥", "_", "_" ])

? o1.FindPrevious("♥", :StartingAt = 5)
#--> 3

? o1.FindNthPrevious(2, "♥", :StartingAt = 7)
#--> 3

? o1.FindNthPrevious(3, "♥", :StartingAt = 9)
#--> 3

StopProfiler()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.07 second(s) in Ring 1.19 (64 bits)
# Executed in 0.04 second(s) in Ring 1.17
