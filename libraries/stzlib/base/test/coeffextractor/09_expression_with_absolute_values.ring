# Narrative
# --------
# Expression with absolute values
#
# Extracted from stzcoeffextractortest.ring, block #9.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"


pr()

cExpr = "abs(demand - supply) + 0.5*inventory"
o1 = new StzCoefficientExtractor(["demand", "supply", "inventory"])

? o1.extractCoefficient(cExpr, "demand")
#--> 1

? o1.extractCoefficient(cExpr, "supply")
#--> -1 (but it returned 1)

? o1.extractCoefficient(cExpr, "inventory")
#--> 0.5

pf()
# Executed in 0.0510 second(s) in Ring 1.22
