# Narrative
# --------
# Variables without explicit coefficients
#
# Extracted from stzcoeffextractortest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

cExpr = "x + 2*y - z"

o1 = new StzCoefficientExtractor(["x", "y", "z"])
? o1.Extract(cExpr, "x")
#--> 1

? o1.Extract(cExpr, "y")
#--> 2

? o1.Extract(cExpr, "z")
#--> -1

pf()
# Executed in 0.0050 second(s) in Ring 1.22
