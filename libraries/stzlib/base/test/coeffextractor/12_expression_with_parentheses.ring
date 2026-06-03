# Narrative
# --------
# Expression with parentheses
#
# Extracted from stzcoeffextractortest.ring, block #12.

load "../../stzBase.ring"


pr()

# cExpr = "(x + y) * 2 + z" shoud be rewritten like this
cExpr = "2*x + 2*y + z"

o1 = new StzCoefficientExtractor(["x", "y", "z"])

? o1.extractCoefficient(cExpr, "x")
#--> 2.0

? o1.extractCoefficient(cExpr, "y")
#--> 2.0

? o1.extractCoefficient(cExpr, "z")
#--> 1

pf()
