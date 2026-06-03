# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #176.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :Before = "♥^")
#--> TRUE

? Q("--♥^^").ContainsXT("^", :After = "-♥")
#--> TRUE

pf()
# Executed in 0.06 second(s)
