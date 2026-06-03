# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #474.
#ERR Error (R14) : Calling Method without definition: inverted

load "../../stzBase.ring"

pr()

? Q("LOVE").Inverted()
#--> EVOL

? Q("LOVE").CharsInverted()	# Or Turned()
#--> ƎɅO⅂

? QQ("L").IsInvertible()	// #NOTE that QQ() elevates "L" to a stzChar
#--> TRUE

pf()
# Executed in 0.07 second(s).
