# Narrative
# --------
# Calculating duration between two datetimes (object param)
#
# Extracted from stzdatetimetest.ring, block #16.

load "../../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime2 = StzDateTimeQ("2024-03-20 14:30:00")

? oDateTime1.DaysTo(oDateTime2)
#--> 5

? oDateTime1.HoursTo(oDateTime2)
#--> 124

? oDateTime1.MinutesTo(oDateTime2)
#--> 7470

? oDateTime1.SecsTo(oDateTime2)
#--> 448200

pf()
# Executed in 0.02 second(s) in Ring 1.24
