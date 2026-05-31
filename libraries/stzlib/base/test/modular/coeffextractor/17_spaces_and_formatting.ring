# Narrative
# --------
# Spaces and formatting
#
# Extracted from stzcoeffextractortest.ring, block #17.

load "../../../stzBase.ring"


pr()

cExpr = "  5 * x  +  3 * y  "
o1 = new StzCoefficientExtractor(["x", "y"])
? o1.extractCoefficient(cExpr, "x")
#--> 5

? o1.extractCoefficient(cExpr, "y")
#--> 3

pf()
# Executed in 0.0050 second(s) in Ring 1.22
