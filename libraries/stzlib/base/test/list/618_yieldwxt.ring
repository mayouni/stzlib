# Narrative
# --------
# YieldW(condition, yielder): map only the matching items to a new value.
#
# YieldW keeps the items that satisfy the condition and yields, for each, the
# value of the yielder expression -- both expressed over @item. Here
# 'isString(@item)' selects the strings and 'upper(@item)' yields each
# uppercased, so [ 1, "ring", 2, "python", 3, "ruby" ] yields
# [ "RING", "PYTHON", "RUBY" ]. W is the single performant + expressive
# conditional form (the old WXT is retired).
#
# Extracted from stzlisttest.ring, block #618.

load "../../stzBase.ring"

pr()

o1 = new stzList([ 1, "ring", 2, "python", 3, "ruby" ])
? @@( o1.YieldW('isString(@item)', 'upper(@item)') )
#--> [ "RING", "PYTHON", "RUBY" ]

pf()
# Executed in 0.15 second(s).
