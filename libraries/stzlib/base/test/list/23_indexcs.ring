# Narrative
# --------
# IndexCS(bCaseSensitive): build a positional index of the list -- each
# distinct item paired with the list of positions where it occurs.
#
# It is an alias of FindItemsCS. With case sensitivity OFF, items are
# folded before grouping, so "B" (positions 2, 6) and "b" (position 7)
# merge into one bucket [ "b", [ 2, 6, 7 ] ]. Note the Softanza
# convention flagged below: when case folding is applied, the keys in the
# output are reported in lowercase. The buckets come out in first-seen
# order.
#
# Extracted from stzlisttest.ring, block #23.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "A", "B", "A", "C", "D", "B", "b" ])
? @@( o1.IndexCS(FALSE) )
#--> [ [ "a", [ 1, 3 ] ], [ "b", [ 2, 6, 7 ] ], [ "c", [ 4 ] ], [ "d", [ 5 ] ] ]

#NOTE: When casesitivity is used, all items are turned to lowercase in the output

pf()
# Executed in almost 0 second(s)
