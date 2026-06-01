# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #177.

load "../../../stzBase.ring"


? Q("^♥^^♥^^♥^").ContainsAtPositions([2, 5, 8], "♥")
#--> TRUE

? Q("♥^^♥^^♥").ContainsAtPosition("♥", 1)

pf()
# Executed in 0.03 second(s)
