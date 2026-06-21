# Narrative
# --------
# AntiPositions() returns the complement of a given set of positions
# within a list's valid index range (1..Size).
#
# Given a list of 10 items and the positions [3, 4, 7, 9], the method
# answers every OTHER position: [1, 2, 5, 6, 8, 10]. This is the
# position-space counterpart to set difference -- instead of asking
# "which items live at these slots", it asks "which slots are left
# over". It is handy for inverting a selection: pick the positions you
# want to exclude, and AntiPositions hands back the ones to keep.
#
# Extracted from stzlisttest.ring, block #285.

load "../../stzBase.ring"

pr()

o1 = new stzList(1:10)
? o1.AntiPositions([ 3, 4, 7, 9 ])
#--> [1, 2, 5, 6, 8, 10 ]

pf()
# Executed in almost 0 second(s).
