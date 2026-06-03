# Narrative
# --------
# pr()
#
# Extracted from stzrandomtest.ring, block #21.

load "../../stzBase.ring"

pr()

Them = [ "Andy", "Bill", "Chris" ]

? AllOf(Them)
#--> [ "Andy", "Bill", "Chris" ]

? @@( NoOneOf(Them) )
#--> [ ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
