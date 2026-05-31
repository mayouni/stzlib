# Narrative
# --------
# Part of day
#
# Extracted from stztimetest.ring, block #29.

load "../../../stzBase.ring"


pr()

oTime1 = new stzTime("09:00:00")
? oTime1.PartOfDay()
#--> morning

oTime2 = new stzTime("14:00:00")
? oTime2.PartOfDay()
#--> afternoon

oTime3 = new stzTime("19:00:00")
? oTime3.PartOfDay()
#--> evening

oTime4 = new stzTime("23:00:00")
? oTime4.PartOfDay()
#--> night

pf()
# Executed in almost 0 second(s) in Ring 1.23
