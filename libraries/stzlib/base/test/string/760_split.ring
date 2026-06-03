# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #760.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

o1 = new stzString("ab-ac-ad")
? o1 / "-" 			# Same as ? o1.Split("-")
#--> [ "ab", "ac", "ad" ]

pf()
# Executed in 0.01 second(s).
