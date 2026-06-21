# Narrative
# --------
# Two flavors of list equality in Softanza: IsEqualTo and IsStrictlyEqualTo.
#
# IsEqualTo treats lists as multisets of values: order does not matter,
# so [ 1, 2 ] is equal to both [ 1, 2 ] and [ 2, 1 ]. IsStrictlyEqualTo
# adds the positional constraint: the items must appear in the same order,
# so [ 1, 2 ] is strictly equal to [ 1, 2 ] but NOT to [ 2, 1 ]. This pair
# lets you choose set-style comparison or sequence-style comparison from the
# same object, depending on whether ordering is semantically meaningful.
#
# Extracted from stzlisttest.ring, block #376.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, 2 ])

? o1.IsEqualTo([ 1, 2 ])
#--> TRUE

? o1.IsEqualTo([ 2, 1 ])
#--> TRUE

? o1.IsStrictlyEqualTo([ 2, 1 ])
#--> FALSE

? o1.IsStrictlyEqualTo([ 1, 2 ])
#--> TRUE

pf()
# Executed in 0.04 second(s).
