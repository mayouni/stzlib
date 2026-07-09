# Narrative
# --------
# Classify() buckets a list's items, mapping each distinct value to the
# 1-based positions where it occurs.
#
# Here the years repeat (1982 appears at positions 1, 4, 7; 1964 at 2, 5;
# 1992 at 3, 8) and Classify() returns a list of [value, positions] pairs
# in first-seen order. The keys are stringified ("1982" not 1982), so the
# result is an inverted index you can use for frequency, dedup, or
# occurrence-tracking. @@SP() renders it as the logical pairs form, not
# the :key = value hashlist syntax the old stub suggested.
#
# Extracted from stzlisttest.ring, block #387.

load "../../stzBase.ring"

pr()

o1 = new stzList([
	1982, 1964, 1992, 1982, 1964, 2001, 1982, 1992, 2000
])

? @@SP( o1.Classify() )
#--> [ [ "1982", [ 1, 4, 7 ] ], [ "1964", [ 2, 5 ] ], [ "1992", [ 3, 8 ] ], [ "2001", [ 6 ] ], [ "2000", [ 9 ] ] ]

#NOTE that list items are stringified.
#ERROR returned []!

pf()
# Executed in 0.01 second(s).
