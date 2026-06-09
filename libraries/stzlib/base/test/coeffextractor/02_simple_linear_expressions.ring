# Narrative
# --------
# Simple linear expressions
#
# Extracted from stzcoeffextractortest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

cExpr = "10*red + 3*green"
o1 = new StzCoefficientExtractor(["red", "green", "blue"])

? o1.Extract(cExpr, "red")
#--> 10

? o1.ExtractCoeff(cExpr, "green")
#--> 3

? o1.ExtractCoefficient(cExpr, "blue")
#--> 0

pf()
# Executed in 0.01 second(s) in Ring 1.22
