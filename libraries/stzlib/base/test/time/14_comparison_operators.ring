# Narrative
# --------
# Comparison operators
#
# Extracted from stztimetest.ring, block #14.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"


pr()

oTime1 = new stzTime("10:00:00")
oTime2 = new stzTime("14:00:00")

? oTime1 < oTime2
#--> TRUE

? oTime1 > oTime2
#--> FALSE

? oTime1 = new stzTime("10:00:00")
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23
