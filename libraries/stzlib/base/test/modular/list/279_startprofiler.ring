# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #279.

load "../../../stzBase.ring"


aList = [ "_", "_", "♥", "_", "_", "♥", "_" ]

? @FindFirst(aList, "♥")
#--> 3

? @FindLast(aList, "♥")
#--> 6

? @FindNext(aList, "♥", :StartingAt = 3)
#--> 6

? @FindPrevious(aList, "♥", :StartingAt = 6)
#--> 3

? @FindNthNext(aList, 1, "♥", :StartingAt = 3)
#--> 6

? @FindNthPrevious(aList, 2, "♥", :StartingAt = 7)
#--> 3

StopProfiler()
# Executed in almost 0 second(s).
