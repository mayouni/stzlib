# Narrative
# --------
# PerformW / PerformAtW: transform matching items IN PLACE.
#
# PerformW(condition, action) walks the list and, for every item the
# condition selects, replaces it with the action's result -- non-matching
# items are left as-is. PerformAtW(positions, condition, action) restricts
# the same transform to the given positions first. Both predicate and action
# are W expressions over @item. Here the strings are uppercased in place, so
# [ 1, "ring", 3, "python", 5, "ruby" ] becomes
# [ 1, "RING", 3, "PYTHON", 5, "RUBY" ]. W is the single performant +
# expressive conditional form (the old WXT is retired); WF is the
# anonymous-function alternative.
#
# Extracted from stzlisttest.ring, block #621.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])
o1.PerformW('isString(@item)', 'upper(@item)')
? @@( o1.Content() )
#--> [ 1, "RING", 3, "PYTHON", 5, "RUBY" ]

o2 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])
o2.PerformAtW([ 2, 4, 6 ], 'isString(@item)', 'upper(@item)')
? @@( o2.Content() )
#--> [ 1, "RING", 3, "PYTHON", 5, "RUBY" ]

pf()
# Executed in 0.14 second(s).
