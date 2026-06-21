# Narrative
# --------
# Collapses a list down to its distinct values with WithoutDuplication().
#
# The list [ "A", "B", "2", "A", "A", "B", 2, 2, "." ] has repeated
# entries. WithoutDuplication() keeps only the first occurrence of each
# value, preserving the original left-to-right order rather than sorting.
# Note that the string "2" and the number 2 are treated as distinct
# items, so both survive the dedup. The same operation is exposed under
# the more set-theoretic alias ToSet(), since a set is by definition a
# collection without repeated members.
#
# Extracted from stzlisttest.ring, block #134.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "2", "A", "A", "B", 2, 2, "." ])
? @@( o1.Withoutduplication() ) # Or ToSet()
#--> [ "A", "B", "2", 2, "." ]

pf()
# Executed in almost 0 second(s) in Ring 1.21
# Executed in 0.04 second(s) in Ring 1.19
