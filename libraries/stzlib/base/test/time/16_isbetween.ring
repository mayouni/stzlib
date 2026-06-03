# Narrative
# --------
# IsBetween
#
# Extracted from stztimetest.ring, block #16.

load "../../stzBase.ring"


pr()

oTime = new stzTime("12:00:00")
? oTime.IsBetween("10:00:00", :And = "14:00:00")
#--> TRUE

? oTime.IsBetween("13:00:00", :And = "14:00:00")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23
