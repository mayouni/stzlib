# Narrative
# --------
# Rounding times
#
# Extracted from stztimetest.ring, block #23.

load "../../stzBase.ring"


pr()

oTime = new stzTime("10:45:30")

oTime2 = oTime.Copy()
oTime2.RoundToNearestHour()
? oTime2.Content()
#--> 11:00:00

oTime3 = new stzTime("10:45:45")
oTime3.RoundToNearestMinute()
? oTime3.Content()
#--> 10:46:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
