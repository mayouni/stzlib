# Narrative
# --------
#
# Extracted from stzcoeffextractortest.ring, block #18.

load "../../stzBase.ring"

pr()

cExpr = "0.15*stocks + 0.04*bonds"
o1 = new StzCoefficientExtractor(["x", "y"])
? o1.extractCoefficient(cExpr, "stocks")
#--> 0.15

? o1.extractCoefficient(cExpr, "bonds")
#--> 0.04

o1.SetVariableNames([ "stocks", "bonds" ])
? @@(o1.extractAllCoefficients(cExpr))
#--> [ 0.1500, 0.0400 ]

pf()
# Executed in 0.0090 second(s) in Ring 1.22
