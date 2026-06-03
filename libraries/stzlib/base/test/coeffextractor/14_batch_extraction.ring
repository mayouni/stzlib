# Narrative
# --------
# Batch extraction
#
# Extracted from stzcoeffextractortest.ring, block #14.

load "../../stzBase.ring"


pr()

cExpr = "2*x + 3*y - z"
o1 = new StzCoefficientExtractor(["x", "y", "z"])
? o1.extractAllCoefficients(cExpr)
#--> [2, 3, -1]

pf()
# Executed in 0.0060 second(s) in Ring 1.22
