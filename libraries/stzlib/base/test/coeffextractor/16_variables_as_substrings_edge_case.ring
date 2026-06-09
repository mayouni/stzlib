# Narrative
# --------
# Variables as substrings (edge case)
#
# Extracted from stzcoeffextractortest.ring, block #16.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

cExpr = "production + production_cost"

o1 = new StzCoefficientExtractor(["production", "production_cost"])
? o1.extractCoefficient(cExpr, "production")
#--> 1

? o1.extractCoefficient(cExpr, "production_cost")
#--> 1

pf()
# Executed in 0.0030 second(s) in Ring 1.22
