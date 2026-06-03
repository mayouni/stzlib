# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #14.
#ERR Error (R14) : Calling Method without definition: isreverseof

load "../../stzBase.ring"

pr()

? Q("ring").IsReverseOf("gnir")
#--> TRUE

? Q(1:3).IsReverseOf(3:1)
#--> TRUE

pf()
# Executed in 0.01 second(s)
