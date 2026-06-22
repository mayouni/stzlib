# Narrative
# --------
# Tests membership and the family of list-comparison predicates,
# including nested sublists as first-class elements.
#
# ListContains() asks whether a value -- here the sublist [2,1] --
# appears as an element of the host list, treating the sublist as a
# single atomic member rather than flattening it. The three StzListQ
# predicates then separate the orthogonal notions of equality:
# HasSameContentAs() ignores order (same multiset of elements),
# HasSameSortingOrderAs() compares the actual positional sequence,
# and IsEqualTo() demands an exact element-by-element match. Reordering
# the elements keeps content equal but breaks sorting-order equality,
# which is why the second call is TRUE while the third is FALSE.
#
# Extracted from stzlisttest.ring, block #431.

load "../../stzBase.ring"

pr()

? ListContains([ "q", "r", [ 2, 1 ] ], [ 2, 1 ])
#--> TRUE

? StzListQ([ "q", "r", [ 2, 1] ]).HasSameContentAs([ "r", [ 2, 1], "q" ])
#--> TRUE

? StzListQ([ "q", "r", [ 2, 1] ]).HasSameSortingOrderAs([ "r", [ 2, 1], "q" ])
#--> FALSE

? StzListQ([ "q", "r", [ 2, 1] ]).IsEqualTo([ "q", "r", [2, 1] ])
#--> TRUE

pf()
# Executed in 0.02 second(s).
