# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #174.

load "../../../stzBase.ring"


? Q("^^♥^^").ContainsXT("^", :BeforePosition = 3)
#--> TRUE

? Q("--♥^^").ContainsXT("^", :AfterPosition = 2)
#--> TRUE

pf()
# Executed in 0.06 second(s)
