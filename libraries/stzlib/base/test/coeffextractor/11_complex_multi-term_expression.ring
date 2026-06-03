# Narrative
# --------
# Complex multi-term expression
#
# Extracted from stzcoeffextractortest.ring, block #11.

load "../../stzBase.ring"


pr()

cExpr = "max([ 0, profit - 1000 ]) + min([ revenue / 100, 50 ]) + cost * 0.1"
o1 = new StzCoefficientExtractor(["profit", "revenue", "cost"])
o1 {
	? Extract(cExpr, "profit")
	#--> 1.0 (but it returned 0)

	? Extract(cExpr, "revenue")
	#--> 0.01

	? ExtractCoefficient(cExpr, "cost")
	#--> 0.1
}

pf()
# Executed in 0.052 second(s) in Ring 1.22
