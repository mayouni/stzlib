# Narrative
# --------
# YieldAtW(positions, condition, yielder): yield over a restricted set of slots.
#
# YieldAtW first narrows the list to the given positions, then yields the
# yielder value for the items there that satisfy the condition. Over
# [ 1, "ring", 3, "python", 5, "ruby" ] at positions [ 2, 4, 6 ] (all the
# strings), 'isString(@item)' matches each and 'upper(@item)' yields them
# uppercased -> [ "RING", "PYTHON", "RUBY" ]. W is the single performant +
# expressive conditional form.
#
# Extracted from stzlisttest.ring, block #620.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "ring", 3, "python", 5, "ruby" ])
? @@( o1.YieldAtW([ 2, 4, 6 ], 'isString(@item)', 'upper(@item)') )
#--> [ "RING", "PYTHON", "RUBY" ]

pf()
# Executed in 0.12 second(s).
