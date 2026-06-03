# Narrative
# --------
# Comparing times with SecsTo and MinutesTo
#
# Extracted from stztimetest.ring, block #13.

load "../../stzBase.ring"


pr()

oTime1 = new stzTime("10:00:00")
oTime2 = new stzTime("14:30:00")

? oTime1.SecsTo(oTime2)
#--> 16200

? oTime1.MinutesTo(oTime2)
#--> 270

? oTime1.HoursTo(oTime2)
#--> 4

pf()
# Executed in almost 0 second(s) in Ring 1.23
