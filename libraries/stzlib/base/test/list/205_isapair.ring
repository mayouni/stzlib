# Narrative
# --------
# IsAPairQ() as a chainable GUARD.
#
# The "...Q" form returns a queryable object instead of a bare boolean:
# when the list really is a pair (exactly 2 items) it hands back a WHOLE-OBJECT
# guard, so a chained .Where(cond) evaluates cond ONCE with @pair bound to the
# whole pair -- @pair[1]/@pair[2] are the pair's two elements (not "index into
# each item"). Here [ :StartingAt, 5 ] is a pair whose first element is a string
# and second a number, so the guard answers TRUE. A non-pair receiver yields a
# false-object whose .Where(...) is 0.
#
# Extracted from stzlisttest.ring, block #205.

load "../../stzBase.ring"

pr()

o1 = new stzList([ :StartingAt, 5 ])
? o1.IsAPairQ().Where('{ isString(@pair[1]) and isNumber(@pair[2]) }')
#--> 1

pf()
# Executed in almost 0 second(s)
