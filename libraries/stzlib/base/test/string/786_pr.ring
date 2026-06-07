# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #786.
#ERR Error (R13) : Object is required

load "../../stzBase.ring"

pr()

? Q("ORingoriaLand") - [ "O", "oria", "Land" ]
#--> Ring

? ( Q("ORingoriaLand") - Q([ "O", "oria", "Land" ]) ).content()
#--> Ring

pf()
# Executed in 0.01 second(s).
