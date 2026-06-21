# Narrative
# --------
# Shrink() truncates a list down to a target position, discarding the tail.
#
# Calling Shrink(:ToPosition = 3) on [ "A", "B", "C", "D", "E" ] keeps only
# the first three items, mutating the object in place so Show() reports the
# shrunken [ "A", "B", "C" ]. The :ToPosition named argument reads as a
# self-documenting "shrink the list so it ends at this position" idiom,
# which is the Softanza preference over a bare numeric truncation length.
#
# Extracted from stzlisttest.ring, block #162.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "C", "D", "E" ])
o1.Shrink( :ToPosition = 3 )
o1.Show()
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.05 second(s)
