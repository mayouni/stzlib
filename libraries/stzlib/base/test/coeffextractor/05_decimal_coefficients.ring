# Narrative
# --------
# Decimal coefficients
#
# Extracted from stzcoeffextractortest.ring, block #5.

load "../../stzBase.ring"


pr()

cExpr = "3.5*price + 0.8*quantity"

o1 = new StzCoeffExtractor(["price", "quantity"])
? o1.Extract(cExpr, "price")
#--> 3.5

? o1.Extract(cExpr, "quantity")
#--> 0.8

pf()
# Executed in 0.0050 second(s) in Ring 1.22
