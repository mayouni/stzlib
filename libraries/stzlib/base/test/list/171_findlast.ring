# Narrative
# --------
# Locating the LAST occurrence of a value in a list with FindLast().
#
# Where Find() returns the position of the first match, FindLast()
# scans for the final one. In [ 1, 2, 3, "*", 5, 6, "*", 8, 9 ] the
# marker "*" appears at positions 4 and 7; FindLast("*") returns 7,
# the rightmost match. This is the natural companion to Find() when
# you care about the tail end of a list rather than the head.
#
# Extracted from stzlisttest.ring, block #171.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8, 9 ])
? o1.FindLast("*")
#--> 7

pf()
# Executed in 0.04 second(s)
