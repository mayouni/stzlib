# Narrative
# --------
# DuplicatesZ vs DuplicatesXTZ -- two "Z" (item + positions) views of the
# repeats in a list.
#
# DuplicatesZ pairs each DUPLICATED item with the positions of its EXTRA
# occurrences only (the first occurrence is dropped). DuplicatesXTZ ("XT"
# = extended) instead pairs EVERY distinct item with ALL of its positions,
# duplicated or not -- a full position index.
#
# The list mixes strings, numbers, sublists ([1,2] via 1:2) and the
# quoted string '"1"'. Each is keyed type-aware, so 1 (number), "1"
# (string, never appears here) and [1,2] (sublist) stay separate, and
# the two [1,2] sublists at positions 8 and 13 are correctly matched.
#
# Extracted from stzlisttest.ring, block #253.

load "../../stzBase.ring"

pr()

aList = [ "A", "B", 1, "A", "A", 1, "C", 1:2, "D", "B", "E", '"1"', 1:2 ]
o1 = new stzList(aList)

? @@( o1.DuplicatesZ() )
#--> [ [ "A", [ 4, 5 ] ], [ "B", [ 10 ] ], [ 1, [ 6 ] ], [ [ 1, 2 ], [ 13 ] ] ]

? ""
? @@( o1.DuplicatesXTZ() )
#--> [ [ "A", [ 1, 4, 5 ] ], [ "B", [ 2, 10 ] ], [ 1, [ 3, 6 ] ], [ "C", [ 7 ] ], [ [ 1, 2 ], [ 8, 13 ] ], [ "D", [ 9 ] ], [ "E", [ 11 ] ], [ '"1"', [ 12 ] ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
