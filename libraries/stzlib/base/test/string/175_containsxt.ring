# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #175.

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :Before = 3)
#--> TRUE

? Q("--♥^^").ContainsXT("^", :After = 2)
#--> TRUE

pf()
# Executed in 0.06 second(s)
