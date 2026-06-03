# Narrative
# --------
# Time of day checks
#
# Extracted from stztimetest.ring, block #17.

load "../../stzBase.ring"


pr()

oMorning = new stzTime("09:00:00")
? oMorning.IsMorning()
#--> TRUE

oAfternoon = new stzTime("14:00:00")
? oAfternoon.IsAfternoon()
#--> TRUE

oEvening = new stzTime("19:00:00")
? oEvening.IsEvening()
#--> TRUE

oNight = new stzTime("23:00:00")
? oNight.IsNight()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23
