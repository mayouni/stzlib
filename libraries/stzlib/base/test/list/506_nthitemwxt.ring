# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #506.
#ERR Error (R14) : Calling Method without definition: nthitemwxt

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
? o1.NthItemWXT(3, :Where = '{ isString(@item) and Q(@item).IsLowercase() }')
#--> "compagon"

pf()
# Executed in 0.15 second(s).
