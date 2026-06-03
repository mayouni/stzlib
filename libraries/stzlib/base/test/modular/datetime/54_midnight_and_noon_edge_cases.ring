# Narrative
# --------
# Midnight and Noon edge cases
#
# Extracted from stzdatetimetest.ring, block #54.

load "../../../stzBase.ring"


pr()

oMidnight = StzDateTimeQ("2024-03-15 00:00:00")
oNoon = StzDateTimeQ("2024-03-15 12:00:00")

? oMidnight.ToString12h()
#--> 2024-03-15 12:00:00 AM (midnight = 12 AM)

? oNoon.ToString12h()
#--> 2024-03-15 12:00:00 PM (noon = 12 PM)

? oMidnight.ToSimple()
#--> 15/03/2024 12:00 AM

? oNoon.ToSimple()
#--> 15/03/2024 12:00 PM

pf()
# Executed in 0.01 second(s) in Ring 1.243
