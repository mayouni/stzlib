# Narrative
# --------
# FindNumbersAsSections: locate the runs of consecutive numbers as
# [start, end] sections.
#
# Instead of every numeric position individually, this groups them into
# contiguous blocks: here numbers sit at 1-4, 7-8, and 11-13, returned as
# the three sections [1,4], [7,8], [11,13]. Useful for spotting numeric
# stretches inside a mixed list.
#
# Extracted from stzlisttest.ring, block #29.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, 4, "A", "B", 7, 8, "C", "D", 11, 12, 13 ])
? @@( o1.FindNumbersAsSections() )
#--> [ [ 1, 4 ], [ 7, 8 ], [ 11, 13 ] ]

pf()
# Executed in almost 0 second(s)
