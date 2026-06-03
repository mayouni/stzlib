# Narrative
# --------
# Working with milliseconds
#
# Extracted from stzdatetimetest.ring, block #31.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")
? oDateTime.ToUnixTimeStampMs()
#--> 1710515445000

? oDateTime.AddMilliseconds(500)
#--> 2024-03-15 14:30:45.500

# Or you can also say:
? oDateTime.ToStringXT("yyyy-MM-dd hh:mm:ss.zzz")
#--> 2024-03-15 14:30:45.500

pf()
# Executed in almost 0 second(s) in Ring 1.23
