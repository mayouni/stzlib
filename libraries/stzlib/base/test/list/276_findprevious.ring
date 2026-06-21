# Narrative
# --------
# Searching a list backwards from a given position with FindPrevious
# and FindNthPrevious.
#
# The list ["1","2","♥","4","♥","6","7"] holds the heart item at
# positions 3 and 5. FindPrevious("♥", :StartingAt = 5) scans toward
# the head from index 5 and reports the nearest earlier match at 3.
# FindNthPrevious(2, "♥", :StartingAt = 6) walks backward from index 6:
# the first earlier heart is at 5, the second earlier one is at 3, so
# it returns 3. These mirror Find/FindNth but reverse the scan direction.
#
# Extracted from stzlisttest.ring, block #276.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "1", "2", "♥", "4", "♥", "6", "7" ])

? o1.FindPrevious("♥", :StartingAt = 5)
#--> 3

? o1.FindNthPrevious(2, "♥", :StartingAt = 6)
#--> 3

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.20
