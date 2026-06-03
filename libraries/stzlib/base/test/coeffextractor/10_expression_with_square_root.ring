# Narrative
# --------
# Expression with square root
#
# Extracted from stzcoeffextractortest.ring, block #10.

load "../../stzBase.ring"


pr()

cExpr = "sqrt(area) + 2*perimeter"
o1 = new StzCoefficientExtractor(["area", "perimeter"])
? o1.extractCoefficient(cExpr, "area")
#--> 0.5 (but it returned 0.1581)

? o1.extractCoefficient(cExpr, "perimeter")
#--> 2

pf()
# Executed in 0.03 second(s) in Ring 1.22
