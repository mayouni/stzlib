# Narrative
# --------
# Internal accelerated find helpers: @FindNthST and @FindNextNthST,
# the fast-path functions stzList uses to locate the Nth occurrence
# of a scalar item starting at a given position.
#
# The ST suffix marks them as the "string/number" specialization:
# they are deliberately limited to finding numbers and strings (the
# common, hot case) so the search can run without the full type
# machinery. To find items of other types, go through stzList. Here
# the heart character sits at positions 3 and 6; asking for the 1st
# heart :StartingAt = 6 returns 6, while @FindNextNthST (which looks
# strictly past the start) finds nothing further and returns 0.
#
# Extracted from stzlisttest.ring, block #281.

load "../../stzBase.ring"

pr()

#REMINDER // functions used internally to accelerate finding in stzLis
#~> Limited to finding only number and strings
#~> To find other types, use stzList

#                    3              6
aList = [ "_", "_", "♥", "_", "_", "♥", "_" ]

? @FindNthST(aList, 1, "♥", :StartingAt = 6)
#--> 6

? @FindNextNthST(aList, 1, "♥", :StartingAt = 6)
#--> 0

pf()
