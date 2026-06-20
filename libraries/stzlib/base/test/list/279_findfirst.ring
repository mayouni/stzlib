# Narrative
# --------
# The global @Find... position helpers (used internally by stzList).
#
# These low-level globals locate an item's position directly on a raw Ring
# list, in every direction:
#   @FindFirst / @FindLast      -- first / last occurrence
#   @FindNext   (:StartingAt=p) -- first occurrence STRICTLY AFTER p
#   @FindPrevious(:StartingAt=p) -- nearest occurrence STRICTLY BEFORE p
#   @FindNthNext / @FindNthPrevious -- the n-th in that direction
# For "♥" at positions 3 and 6: next-after-3 is 6, previous-before-6 is 3,
# and the 2nd-previous-before-7 walks back 6 then 3.
#
# Extracted from stzlisttest.ring, block #279.

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
# Executed in almost 0 second(s)
