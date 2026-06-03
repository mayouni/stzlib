# Narrative
# --------
# 12-hour format operations
#
# Extracted from stztimetest.ring, block #7.

load "../../stzBase.ring"


pr()

oTime = new stzTime("14:30:00")

? oTime.Hour12()
#--> 2

? oTime.AMPM()
#--> PM

? oTime.To12Hour()
#--> 2:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
