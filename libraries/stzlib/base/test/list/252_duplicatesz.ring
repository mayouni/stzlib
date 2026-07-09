# Narrative
# --------
# DuplicatesZ() reports each duplicated value together with the positions
# of its REDUNDANT occurrences (every appearance after the first).
#
# Given a list with repeats, the Z-form returns a list of pairs
# [ value, [ positions ] ] where the positions are only those of the
# later copies -- the first occurrence is treated as the canonical one
# and omitted. So 1 (first at 1, again at 6) yields [ 1, [ 6 ] ],
# "*" (first at 2, again at 7 and 10) yields [ "*", [ 7, 10 ] ], and the
# range literal 10:12 -- materialized as the list [ 10, 11, 12 ] -- is a
# value in its own right, duplicated once at position 12. Use this when
# you need not just "what repeats" but "where the extra copies are."
#
# Extracted from stzlisttest.ring, block #252.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "*", 10:12, "B", 2, 1, "*", "A", 3, "*", "B", 10:12, "B" ])
? @@( o1.DuplicatesZ() )
#--> [ [ 1, [ 6 ] ], [ "*", [ 7, 10 ] ], [ [ 10, 11, 12 ], [ 12 ] ], [ "B", [ 11, 13 ] ] ]

pf()
# Executed in almost 0 second(s) in Ring 1.27
