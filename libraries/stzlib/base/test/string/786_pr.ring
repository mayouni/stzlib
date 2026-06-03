# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #786.
#ERR Error (R50) : Object does not support operator overloading

load "../../stzBase.ring"

pr()

? Q("ORingoriaLand") - [ "O", "oria", "Land" ]
#--> Ring

? ( Q("ORingoriaLand") - Q([ "O", "oria", "Land" ]) ).content()
#--> Ring

pf()
# Executed in 0.01 second(s).
