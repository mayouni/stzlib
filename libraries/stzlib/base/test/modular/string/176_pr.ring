# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #176.

load "../../../stzBase.ring"


? Q("^^♥^^").ContainsXT("^", :Before = "♥^")
#--> TRUE

? Q("--♥^^").ContainsXT("^", :After = "-♥")
#--> TRUE

pf()
# Executed in 0.06 second(s)
