# Narrative
# --------
# Comparing datetimes with operators (object)
#
# Extracted from stzdatetimetest.ring, block #20.

load "../../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime2 = StzDateTimeQ("2024-03-20 10:00:00")

? oDateTime1 < oDateTime2
#--> TRUE

? oDateTime1 > oDateTime2
#--> FALSE

? oDateTime1 = oDateTime1
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.23
