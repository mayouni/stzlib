# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #173.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :AfterPosition = 2)
? Q("^^♥^^").ContainsInSection("^", 5, 3)

pf()
# Executed in 0.04 second(s) in Ring 1.21
