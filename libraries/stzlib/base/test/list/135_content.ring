# Narrative
# --------
# Strips every singleton from a list, keeping only items that recur.
#
# RemoveNonDuplicates() is the complement of a dedup pass: instead of
# collapsing repeats it discards the values that appear exactly once,
# preserving the original order and every occurrence of the survivors.
# Here "2" (the string) and "." occur a single time and are dropped,
# while "A", "B" and the number 2 each appear more than once and stay.
# Note that the string "2" and the number 2 are distinct items, so the
# lone string "2" is removed while the two numeric 2s are retained.
#
# Extracted from stzlisttest.ring, block #135.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
o1.RemoveNonDuplicates()
? @@(o1.Content())
#--> [ "A", "B", "A", "A", "B", 2, 2 ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19

# Enhancing Your Mental Model with Softanza: A Case Study of List Sorting
# Let's explore how Softanza improves the programming experience by examining
# the sort() function implementation
