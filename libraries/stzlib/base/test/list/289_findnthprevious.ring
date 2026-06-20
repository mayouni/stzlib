# Narrative
# --------
# FindNthPrevious with a SUBLIST needle, and the "not enough occurrences"
# case -> 0.
#
# The needle here is the sublist "A":"C" (= [ "A","B","C" ]). Scanning back
# from position 7 for the 2nd earlier occurrence: there is only ONE
# occurrence before position 7 (at position 4), so the 2nd doesn't exist
# and FindNthPrevious returns 0. (This exercises the finder's type-aware
# matching: sublist items are compared by content, not byte-concatenated.)
#
# Extracted from stzlisttest.ring, block #289.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "A":"C", 5, 7, 8, 9, "A":"C" ])
? o1.FindNthPrevious(2, "A":"C", :StartingAt = 7)
#--> 0

StopProfiler()

pf()
# Executed in almost 0 second(s)
