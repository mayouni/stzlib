# Narrative
# --------
# Removing a recurring item from a list, returning a fresh copy.
#
# ItemRemoved(item) returns a new list with every occurrence of the
# given value stripped out, leaving the original untouched. Here the
# pair 1:3 appears twice between the "A"/"B"/"C" markers; passing 1:3
# removes both, yielding [ "A", "B", "C" ]. ItemRemovedW(condition)
# is the predicate-driven sibling: it removes every item for which the
# W-expression holds. Using 'isList(This[@i])' it drops both pairs
# (they are lists), reaching the same [ "A", "B", "C" ] result.
#
# Extracted from stzlisttest.ring, block #399.

load "../../stzBase.ring"

pr()

? Q([ "A", 1:3, "B", 1:3, "C" ]).ItemRemoved(1:3)
#--> [ "A", "B", "C" ]

? Q([ "A", 1:3, "B", 1:3, "C" ]).ItemRemovedW('isList(This[@i])')
#--> [ "A", "B", "C" ]

pf()
# Executed in 0.04 second(s).
