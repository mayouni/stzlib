# Narrative
# --------
# FindNthPrevious with a SUBLIST needle -- the success case.
#
# Here "A":"C" (= [ "A","B","C" ]) occurs at positions 4 and 5 before the
# start position 7. Scanning backward, the 1st previous is at 5 and the
# 2nd previous is at 4 -> FindNthPrevious returns 4. Sublist items are
# matched by content (the finder stringifies them type-aware).
#
# Extracted from stzlisttest.ring, block #290.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "A":"C", "A":"C", 6, 7, "A":"C" ])
? o1.FindNthPrevious(2, "A":"C", :StartingAt = 7)
#--> 4

StopProfiler()

pf()
# Executed in almost 0 second(s)
