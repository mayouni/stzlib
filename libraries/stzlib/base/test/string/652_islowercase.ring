# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #652.
#ERR Error (R14) : Calling Method without definition: islowercaseof

load "../../stzBase.ring"

pr()

? Q("date").IsLowercase()
#--> TRUE

? Q("date").IsLowercaseOf("DATE")
#--> TRUE

pf()
# Executed in 0.03 second(s)
