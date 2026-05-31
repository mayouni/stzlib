# Narrative
# --------
# Creating time from hash list
#
# Extracted from stztimetest.ring, block #3.

load "../../../stzBase.ring"


pr()

oTime = new stzTime([:Hour = 14, :Minute = 30, :Second = 45])
? oTime.ToString()
#--> 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23
