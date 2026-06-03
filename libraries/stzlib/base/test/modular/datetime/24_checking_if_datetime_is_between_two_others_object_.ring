# Narrative
# --------
# Checking if datetime is between two others (object params)
#
# Extracted from stzdatetimetest.ring, block #24.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-17 10:00:00")
oStart = StzDateTimeQ("2024-03-15 10:00:00")
oEnd = StzDateTimeQ("2024-03-20 10:00:00")
? oDateTime.IsBetween(oStart, :And = oEnd)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.24
