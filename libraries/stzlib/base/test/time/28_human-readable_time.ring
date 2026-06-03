# Narrative
# --------
# Human-readable time
#
# Extracted from stztimetest.ring, block #28.

load "../../stzBase.ring"


pr()

oTime1 = new stzTime("14:00:00")
? oTime1.ToHuman()
#--> 2 o'clock PM

oTime2 = new stzTime("14:15:00")
? oTime2.ToHuman()
#--> Quarter past 2 PM

oTime3 = new stzTime("14:30:00")
? oTime3.ToHuman()
#--> Half past 2 PM

oTime4 = new stzTime("14:45:00")
? oTime4.ToHuman()
#--> Quarter to 3 PM

pf()
# Executed in almost 0 second(s) in Ring 1.23
