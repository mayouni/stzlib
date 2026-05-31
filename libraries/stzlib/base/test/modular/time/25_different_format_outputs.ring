# Narrative
# --------
# Different format outputs
#
# Extracted from stztimetest.ring, block #25.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("14:30:45")

? oTime.To12Hour()
#--> 2:30:45 PM

? oTime.To24Hour()
#--> 14:30:45

? oTime.ToShort()
#--> 14:30

? oTime.ToSimple()
#--> 2:30 PM

? oTime.AMPM()
#~-> PM

pf()
# Executed in almost 0 second(s) in Ring 1.23
