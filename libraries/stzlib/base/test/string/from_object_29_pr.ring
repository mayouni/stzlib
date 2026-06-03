# Narrative
# --------
# pr()
#
# Extracted from stzObjectTest.ring, block #29.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

o1 = new stzString("hello")
? o1.Is(:StzString)
#--> TRUE

pf()
# Executed in 0.03 second(s)
