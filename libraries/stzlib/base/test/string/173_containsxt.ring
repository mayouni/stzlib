# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #173.
#

load "../../stzBase.ring"

pr()

? Q("^^♥^^").ContainsXT("^", :AfterPosition = 2) #--> TRUE
? Q("^^♥^^").ContainsInSection("^", 5, 3)        #--> TRUE

pf()
