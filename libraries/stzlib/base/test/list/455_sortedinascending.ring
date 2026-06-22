# Narrative
# --------
# SortedInAscending() returns a new copy of the list ordered from
# smallest to largest, leaving the original list untouched.
#
# Softanza distinguishes the "...ed" query form (SortedInAscending)
# from the in-place verb form (SortInAscending): the participle
# returns a fresh sorted list while the receiver keeps its original
# order, so it composes cleanly inside expressions. Here [ 5, 7, 9, 2 ]
# yields [ 2, 5, 7, 9 ] on numeric ascending order.
#
# Extracted from stzlisttest.ring, block #455.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 5, 7, 9, 2 ])
? o1.SortedInAscending()
#--> [ 2, 5, 7, 9 ]

pf()
# Executed in almost 0 second(s).
