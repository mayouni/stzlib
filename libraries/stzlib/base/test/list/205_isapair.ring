# Narrative
# --------
# IsAPairQ() as a chainable GUARD.
#
# The "...Q" form returns a queryable object instead of a bare boolean:
# when the list really is a pair (exactly 2 items) it returns the list
# itself, so you can keep chaining; otherwise it returns a false-object
# that short-circuits the chain. Here [ :StartingAt, 5 ] is a pair, so
# IsAPairQ() hands back the stzList and we chain a .Where(...) filter on
# it. The condition is written against @pair; in this item-wise Where it
# matches nothing, so the filtered result is the empty list.
#
# Extracted from stzlisttest.ring, block #205.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :StartingAt, 5 ])
? @@( o1.IsAPairQ().Where('{ isString(@pair[1]) and isNumber(@pair[2]) }') )
#--> [ ]

pf()
# Executed in almost 0 second(s)
