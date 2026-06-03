# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #178.

load "../../stzBase.ring"


? Q("♥^^♥^^♥").ContainsAt([1, 4, 7], "♥")
#--> TRUE

? Q("♥^^♥^^♥").ContainsXT("♥", :AtPositions = [1, 4, 7])
#--> TRUE

pf()
# Executed in 0.07 second(s)
