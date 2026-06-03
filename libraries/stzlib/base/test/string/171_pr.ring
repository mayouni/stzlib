# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #171.

load "../../stzBase.ring"


? Q("^^♥^^").ContainsInSection("♥", 2, 4)
#--> TRUE

? Q("^^♥^^").ContainsBetweenPositions("♥", 2, 4)
#--> TRUE

//? Q("^^♥^^").ContainsBoundedBy("♥", :Positions = [ 2, 4])
#--> TRUE

? Q("^^♥^^").ContainsInSection("♥", 1, 3)
#--> TRUE

pf()
# Executed in 0.05 second(s)
