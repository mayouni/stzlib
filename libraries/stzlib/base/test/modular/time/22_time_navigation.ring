# Narrative
# --------
# Time navigation
#
# Extracted from stztimetest.ring, block #22.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("10:30:00")

? oTime.NextHour()
#--> 11:30:00

? oTime.PreviousHour()
#--> 10:30:00

? oTime.NextMinute()
#--> 10:31:00

? oTime.PreviousMinute()
#--> 10:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
