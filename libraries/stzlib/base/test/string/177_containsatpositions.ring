# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #177.
#ERR Error (R14) : Calling Method without definition: containsatpositions

load "../../stzBase.ring"

pr()

? Q("^♥^^♥^^♥^").ContainsAtPositions([2, 5, 8], "♥")
#--> TRUE

? Q("♥^^♥^^♥").ContainsAtPosition("♥", 1)

pf()
# Executed in 0.03 second(s)
