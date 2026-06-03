# Narrative
# --------
# Expression with division
#
# Extracted from stzcoeffextractortest.ring, block #7.
#ERR Error (C27) : Syntax Error!

load "../../stzBase.ring"


pr()

cExpr = "staff_count / 8 + overtime_hours / 4"

o1 = new StzCoefficientExtractor(["staff_count", "overtime_hours"])
? o1.extractCoefficient(cExpr, "staff_count")
#--> 0.125


? o1.extractCoefficient(cExpr, "overtime_hours")
#--> 0.25

pf()
# Executed in 0.0360 second(s) in Ring 1.22
