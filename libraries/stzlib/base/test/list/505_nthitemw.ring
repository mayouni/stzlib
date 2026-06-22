# Narrative
# --------
# Fetch the Nth item that satisfies a predicate, using the WF (anonymous-
# function) variant of the conditional API.
#
# NthItemWF(n, func) walks the list, keeps only items for which the
# function returns TRUE, and returns the Nth survivor. Here the predicate
# keeps strings that are entirely lowercase, so from
# [ "ami", "coupain", "CAMARADE", "compagon" ] the lowercase items are
# "ami", "coupain", "compagon" and the 3rd is "compagon".
# The WF form is used (instead of the W engine-DSL form) because the
# condition calls a Ring method, Q(x).IsLowercase(), which the engine
# DSL has no dispatch for by design -- the anonymous function gives the
# same result while allowing arbitrary Ring code in the test.
#
# Extracted from stzlisttest.ring, block #505.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
# Migrated to WF: the W condition called a Ring method (Q(..).IsLowercase()),
# which the engine DSL has no dispatch for by design -> use the anonymous-
# function form. Same result.
? o1.NthItemWF(3, func x { return isString(x) and Q(x).IsLowercase() })
#--> "compagon"

pf()
# Executed in 0.13 second(s).
