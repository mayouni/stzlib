# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #171.
#

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsInSection("♥", 2, 4)        #--> TRUE
? Q("^^♥^^").ContainsBetweenPositions("♥", 2, 4) #--> TRUE
? Q("^^♥^^").ContainsInSection("♥", 1, 3)        #--> TRUE

pf()
