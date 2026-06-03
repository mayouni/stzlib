# Narrative
# --------
# Work hours check
#
# Extracted from stztimetest.ring, block #20.

load "../../stzBase.ring"


pr()

oTime1 = new stzTime("10:00:00")
? oTime1.IsWorkHours()
#--> TRUE

oTime2 = new stzTime("18:00:00")
? oTime2.IsWorkHours()
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23
