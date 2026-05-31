# Narrative
# --------
# Special time checks
#
# Extracted from stztimetest.ring, block #19.

load "../../../stzBase.ring"


pr()

oMidnight = new stzTime("00:00:00")
? oMidnight.IsMidnight()
#--> TRUE

oNoon = new stzTime("12:00:00")
? oNoon.IsNoon()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23
