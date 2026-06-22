# Narrative
# --------
# Walks backwards from a start position to find the Nth earlier occurrence of a value.
#
# FindPreviousNthOccurrence(n, :Of = value, :StartingAt = pos) scans the list
# leftward beginning at pos and returns the position of the n-th match before it.
# Here "mix" sits at positions 2, 5, and 7. Starting at position 6 and looking
# back, the 1st previous "mix" is at 5 and the 2nd is at 2 -- so the call returns 2.
# This is the mirror of FindNextNthOccurrence, giving directional, count-based
# lookup that is more expressive than a single Find.
#
# Extracted from stzlisttest.ring, block #492.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "mio", "mix", "mia", "mio", "mix", "miz", "mix" ])

? o1.FindPreviousNthOccurrence( 2, :Of = "mix", :StartingAt = 6)
#--> 2

pf()
# Executed in 0.05 second(s).
