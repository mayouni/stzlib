# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #170.
#ERR Error (R14) : Calling Method without definition: containsat

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsAt(3, "♥")
#--> TRUE

? Q("^^♥^^").ContainsAt("♥", :Position = 3)
#--> TRUE

? Q("^^♥^^").ContainsXT("♥", :AtPosition = 3)
#--> TRUE

pf()
# Executed in 0.02 second(s) in Ring 1.21
