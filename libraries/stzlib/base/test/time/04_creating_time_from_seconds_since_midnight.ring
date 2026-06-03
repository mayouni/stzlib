# Narrative
# --------
# Creating time from seconds since midnight
#
# Extracted from stztimetest.ring, block #4.

load "../../stzBase.ring"


pr()

oTime = new stzTime(52245)
? oTime.ToString()
#--> 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23
