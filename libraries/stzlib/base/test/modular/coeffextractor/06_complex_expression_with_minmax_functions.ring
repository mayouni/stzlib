# Narrative
# --------
# Complex expression with min/max functions
#
# Extracted from stzcoeffextractortest.ring, block #6.

load "../../../stzBase.ring"

pr()

cExpr = "min([ beds_dept1 / 20, 1 ]) * 100 + min([ beds_dept2 / 15, 1 ]) * 100"
o1 = new StzCoefficientExtractor(["beds_dept1", "beds_dept2"])
? o1.Extract(cExpr, "beds_dept1")
#--> 5.0

? o1.extract(cExpr, "beds_dept2")
#--> 6.6667

pf()
# Executed in 0.0320 second(s) in Ring 1.22
