# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #505.
#ERR Error (R14) : Calling Method without definition: nthitemw

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
