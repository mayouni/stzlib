# Narrative
# --------
# Index(): a positional index of the list -- each distinct item paired with
# all the positions where it occurs.
#
# The case-sensitive default of FindItems/IndexCS: "A" at positions 1 and 3,
# "B" at 2 and 6, the singletons "C" and "D" at 4 and 5. The buckets come
# out in first-seen order. (See 23_indexcs for the case-folding dial.)
#
# Extracted from stzlisttest.ring, block #22.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "A", "C", "D", "B" ])
? @@( o1.Index() )
#--> [ [ "A", [ 1, 3 ] ], [ "B", [ 2, 6 ] ], [ "C", [ 4 ] ], [ "D", [ 5 ] ] ]

pf()
# Executed in almost 0 second(s)
