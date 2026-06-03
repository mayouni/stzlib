# Narrative
# --------
# Copying time objects
#
# Extracted from stztimetest.ring, block #30.

load "../../stzBase.ring"


pr()

oTime1 = new stzTime("14:30:00")
oTime2 = oTime1.Copy()
oTime2.AddHours(2)

? oTime1.ToString()
#--> 14:30:00

? oTime2.ToString()
#--> 16:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
