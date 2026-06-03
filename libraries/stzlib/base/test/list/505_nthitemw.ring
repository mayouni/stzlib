# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #505.
#ERR Error (R14) : Calling Method without definition: nthitemw

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
? o1.NthItemW(3, :Where = '{ isString(This[@i]) and Q(This[@i]).IsLowercase() }')
#--> "compagon"

pf()
# Executed in 0.13 second(s).
