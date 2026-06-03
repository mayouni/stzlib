# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #178.
#ERR Error (R14) : Calling Method without definition: containsat

load "../../stzBase.ring"

pr()

? Q("♥^^♥^^♥").ContainsAt([1, 4, 7], "♥")
#--> TRUE

? Q("♥^^♥^^♥").ContainsXT("♥", :AtPositions = [1, 4, 7])
#--> TRUE

pf()
# Executed in 0.07 second(s)
