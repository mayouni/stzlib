# Narrative
# --------
# FindWF returns the positions of items that satisfy an anonymous filter function.
#
# The list mixes string placeholders with range-pair values (1:3 and 5:9).
# The filter func x { return Q(x).IsOneOfThese([ 1:3, 5:9 ]) } keeps only
# the items that equal one of those two ranges. The "_" strings are rejected,
# so FindWF yields the two positions where the ranges live: 3 and 5. This is
# the function-driven sibling of FindW (engine DSL), letting you express the
# match predicate in plain Ring with Q()-wrapped value comparisons.
#
# Extracted from stzlisttest.ring, block #476.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "_", "_", 1:3, "_", 5:9, "_" ])
? o1.FindWF( func x { return Q(x).IsOneOfThese([ 1:3, 5:9 ]) } )
#--> [ 3, 5 ]

pf()
# Executed in 0.13 second(s).
