# Narrative
# --------
# Morning times (AM)
#
# Extracted from stzdatetimetest.ring, block #52.

load "../../../stzBase.ring"


pr()

oMorning = StzDateTimeQ("2024-03-15 09:15:30")

? oMorning.ToSimple()
#--> 15/03/2024 9:15 AM

? oMorning.ToSimple12h()
#--> 15/03/2024 9:15 AM

? oMorning.ToSimple24h()
#--> 15/03/2024 09:15

? oMorning.ToStringXT("h:mm AP")
#--> 9:15 AM

pf()
# Executed in 0.01 second(s) in Ring 1.24
