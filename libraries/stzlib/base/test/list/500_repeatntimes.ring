# Narrative
# --------
# RepeatNTimes(n): repeat a list as n NESTED copies -- a FEATURE STUB.
#
# The intent is RepeatNTimes(n) -> n nested copies of the list, e.g.
# [1,2,3] -> [ [1,2,3], [1,2,3], [1,2,3] ]. stzList does not implement this:
# the only repeat methods are Repeat(n)/Repeated(n), which FLATTEN
# ([1,2,3] -> [1,2,3,1,2,3,1,2,3]). The unknown RepeatNTimes call resolves to
# the operator/Brace fallback and silently yields an empty result (so @@NL
# prints nothing). The recorded block shows the intended nested shape. Left as
# a documented stub until a nesting RepeatNTimes is added (or the test is
# rewritten onto Repeated()).
#
# Extracted from stzlisttest.ring, block #500.
#ERR (RepeatNTimes not implemented -- only the flattening Repeat/Repeated exist)

load "../../stzBase.ring"

pr()

? @@NL( StzListQ([ 1, 2, 3 ]).RepeatNTimes(3) )
#--> [
#	[ 1, 2, 3 ],
#	[ 1, 2, 3 ],
#	[ 1, 2, 3 ]
# ]

pf()
# Executed in 0.02 second(s).
