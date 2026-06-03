# Narrative
# --------
# Expression validation
#
# Extracted from stzcoeffextractortest.ring, block #15.

load "../../stzBase.ring"


pr()

cExpr = "invalid_function(x) + y"
o1 = new StzCoefficientExtractor(["x", "y"])
? o1.validateExpression(cExpr)
#--> FALSE


cExpr = "2*x + 3*y"
? o1.validateExpression(cExpr)
#--> TRUE

pf()
# Executed in 0.0020 second(s) in Ring 1.22
