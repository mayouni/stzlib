# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #731.
#ERR Error (R14) : Calling Method without definition: stringcase

load "../../stzBase.ring"

pr()

? StzStringQ("ring").StringCase()
#--> :Lowercase

? StzStringQ("RING").StringCase()
#--> :Uppercase

? StzStringQ("RING and python").StringCase()
#--> :hybridcase

pf()
# Executed in 0.25 second(s).
