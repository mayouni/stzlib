# Narrative
# --------
# Expression with power operations
#
# Extracted from stzcoeffextractortest.ring, block #8.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"


pr()

# cExpr = "x^2 + 3*y^2 + 2*z" --> should be ringified like this
cExpr = "pow(x, 2) + 3 * pow(y, 2) + 2*z"

o1 = new StzCoefficientExtractor([ "x", "y", "z" ])
? o1.extractCoefficient(cExpr, "x")
#--> 2.0 (but it returned 20.001)

? o1.extractCoefficient(cExpr, "y")
#--> 6.0 (but it returned 60.003)

? o1.extractCoefficient(cExpr, "z")
#--> 2

pf()
# Executed in 0.0490 second(s) in Ring 1.22
