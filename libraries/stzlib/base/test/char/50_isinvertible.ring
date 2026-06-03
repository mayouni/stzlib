# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #50.
#ERR Error (R14) : Calling Method without definition: isinvertible

load "../../stzBase.ring"

pr()

? StzCharQ("v").IsInvertible() #--> TRUE
? StzCharQ("v").Inverted() #--> ʌ

pf()
# Executed in 0.04 second(s) in Ring 1.23
