# Narrative
# --------
# Zero coefficient case
#
# Extracted from stzcoeffextractortest.ring, block #13.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

cExpr = "a + b"
o1 = new StzCoefficientExtractor(["a", "b", "c"])
? o1.extractCoefficient(cExpr, "c")
#--> 0

pf()
# Executed in 0.002 second(s) in Ring 1.22
