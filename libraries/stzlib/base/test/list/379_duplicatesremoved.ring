# Narrative
# --------
# Shows DuplicatesRemoved() returning a deduplicated copy of a stzList.
#
# Given [ 4, 1, 2, 1, 1, 2, 3, 3, 3 ], the method keeps the first
# appearance of each value and discards every later repeat, yielding
# [ 4, 1, 2, 3 ]. Order is driven by first-seen position, not by
# sorting, so 4 stays in front even though 1, 2, 3 are smaller. The
# source list is left untouched; the result is a fresh list.
#
# Extracted from stzlisttest.ring, block #379.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 4, 1, 2, 1, 1, 2, 3, 3, 3 ])
? o1.DuplicatesRemoved()
#--> [ 4, 1, 2, 3 ]

pf()
# Executed in almost 0 second(s).
