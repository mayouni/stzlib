# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #786.

load "../../../stzBase.ring"


? Q("ORingoriaLand") - [ "O", "oria", "Land" ]
#--> Ring

? ( Q("ORingoriaLand") - Q([ "O", "oria", "Land" ]) ).content()
#--> Ring

pf()
# Executed in 0.01 second(s).
