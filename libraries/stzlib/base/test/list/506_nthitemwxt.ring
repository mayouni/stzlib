# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #506.

load "../../stzBase.ring"

pr()

o1 = new stzList([ "ami", "coupain", "CAMARADE", "compagon" ])
? o1.NthItemWF(3, func x { return isString(x) and Q(x).IsLowercase() } )
#--> "compagon"

pf()
# Executed in 0.15 second(s).
