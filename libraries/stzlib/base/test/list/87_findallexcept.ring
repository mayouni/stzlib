# Narrative
# --------
# FindAllExcept() returns the positions of every item that is NOT a
# member of the supplied exclusion list.
#
# Here the list [ "heart", "A", "B", "C", "heart" ] is scanned against
# the exclusion set [ "A", "B", "C" ]. The two heart symbols at
# positions 1 and 5 are the only items not in the set, so the method
# yields [ 1, 5 ]. This is the complement of a value-membership search:
# instead of "where do these values live", it answers "where does
# anything else live". FindItemsOtherThan() is the readable alias for
# the same operation.
#
# Extracted from stzlisttest.ring, block #87.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "♥", "A", "B", "C", "♥" ])
? o1.FindAllExcept([ "A", "B", "C" ]) # Or FindItemsOtherThan()
#--> [1, 5]

pf()
# Executed in 0.04 second(s)
