# Narrative
# --------
# Getting time components
#
# Extracted from stztimetest.ring, block #6.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("14:30:45")
? oTime.Hour()
#--> 14

? oTime.Minute()
#--> 30

? oTime.Second()
#--> 45

pf()
# Executed in almost 0 second(s) in Ring 1.23
