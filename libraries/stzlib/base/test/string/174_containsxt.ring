# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #174.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :BeforePosition = 3)
#--> TRUE

? Q("--♥^^").ContainsXT("^", :AfterPosition = 2)
#--> TRUE

pf()
# Executed in 0.06 second(s)
