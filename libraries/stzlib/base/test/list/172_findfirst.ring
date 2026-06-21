# Narrative
# --------
# FindFirst() returns the 1-based position of the first occurrence of an item.
#
# Given a list that contains a value more than once, FindFirst("*") scans
# left-to-right and stops at the earliest match, returning its index. Here
# the list [ 1, 2, 3, "*", 5, 6, "*", 8, 9 ] holds two "*" markers, at
# positions 4 and 7; FindFirst reports 4, the leftmost. It is the
# single-result counterpart to FindAll, useful when only the first hit
# matters. A missing item yields 0.
#
# Extracted from stzlisttest.ring, block #172.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2, 3, "*", 5, 6, "*", 8, 9 ])
? o1.FindFirst("*")
#--> 4

pf()
# Executed in 0.05 second(s)
