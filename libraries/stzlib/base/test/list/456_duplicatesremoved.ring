# Narrative
# --------
# DuplicatesRemoved() returns a copy of the list with repeated items
# dropped, keeping each value's first appearance in original order.
#
# Here the list holds "hussein" twice; the returned list collapses it
# to a single occurrence, yielding [ "teeba", "hussein", "haneen" ].
# Crucially this is a non-mutating query: the source o1 is untouched,
# so NumberOfItems() still reports 4 afterwards. Softanza pairs a
# read-only "*Removed" form with an in-place "Remove*" form so callers
# pick mutation explicitly rather than by accident.
#
# Extracted from stzlisttest.ring, block #456.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "teeba", "hussein", "haneen" , "hussein" ])

? o1.DuplicatesRemoved()
#--> [ "teeba", "hussein", "haneen" ]

? o1.NumberOfItems()
#--> 4

pf()
# Executed in almost 0 second(s).
