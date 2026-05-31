# Narrative
# --------
# Custom format strings
#
# Extracted from stztimetest.ring, block #26.

load "../../../stzBase.ring"


pr()

oTime = new stzTime("14:30:45")

? oTime.ToStringXT("hh:mm")
#--> 14:30

? oTime.ToStringXT("h:mm AP")
#--> 2:30 PM

? oTime.ToStringXT("HH:mm:ss")
#--> 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23
