# Narrative
# --------
# Creating time from string
#
# Extracted from stztimetest.ring, block #2.

load "../../stzBase.ring"


pr()

oTime = new stzTime("14:30:00")
? oTime.Content()
#--> 14:30:00

oTime2 = new stzTime("14:30")
? oTime2.Content()
#--> 14:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
