# Narrative
# --------
# IsBefore, IsAfter, IsEqualTo
#
# Extracted from stztimetest.ring, block #15.

load "../../../stzBase.ring"


pr()

oTime1 = new stzTime("10:00:00")
oTime2 = new stzTime("14:00:00")

? oTime1.IsBefore(oTime2)
#--> TRUE

? oTime1.IsAfter(oTime2)
#--> FALSE

? oTime1.IsEqualTo("10:00:00")
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23
