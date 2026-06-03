# Narrative
# --------
# Comparing datetimes with operators (string)
#
# Extracted from stzdatetimetest.ring, block #19.

load "../../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
? oDateTime1 < "2024-03-20 10:00:00"
#--> TRUE

? oDateTime1 > "2024-03-20 10:00:00"
#--> FALSE

? oDateTime1 = "2024-03-15 10:00:00"
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.24
