# Narrative
# --------
# Negative coefficients
#
# Extracted from stzcoeffextractortest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

cExpr = "5*x - 3*y + 2*z"

o1 = new StzCoefficientExtractor(["x", "y", "z"])

? o1.Extract(cExpr, "x")
#--> 5

? o1.Extract(cExpr, "y")
#--> -3

? o1.Extract(cExpr, "z")
#--> 2

pf()
# Executed in 0.01 second(s) in Ring 1.22
