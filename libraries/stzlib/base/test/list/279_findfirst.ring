# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #279.
#ERR Error (R3) : Calling Function without definition: @findprevious

load "../../stzBase.ring"

pr()

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

pf()
# Executed in almost 0 second(s).
