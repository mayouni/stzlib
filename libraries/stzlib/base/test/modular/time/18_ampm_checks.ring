# Narrative
# --------
# AM/PM checks
#
# Extracted from stztimetest.ring, block #18.

load "../../../stzBase.ring"


pr()

oTime1 = new stzTime("09:00:00")
? oTime1.IsAM()
#--> TRUE

oTime2 = new stzTime("15:00:00")
? oTime2.IsPM()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23
