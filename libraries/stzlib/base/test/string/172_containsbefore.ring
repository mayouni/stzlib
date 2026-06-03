# Narrative
# --------
# *
#
# Extracted from stzStringTest.ring, block #172.
#ERR Error (R14) : Calling Method without definition: containsbefore

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsBefore("♥", :Position = 4)
#--> TRUE

? Q("^^^♥^").ContainsAfter("♥", 3)
#--> TRUE

? Q("--♥--^^").ContainsBefore("♥", :SubString = "^^")
#--> TRUE

? Q("--^^--♥^^").ContainsAfter("♥", "^^")
#--> TRUE

pf()
# Executed in 0.06 second(s)
