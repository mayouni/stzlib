# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #28.

load "../../stzBase.ring"


o1 = new stzNumber(12500)

? o1.Is(:StzNumber)
#--> TRUE

? o1.Is(:String)
#--> FALSE

pf()
# Executed in 0.03 second(s)
