# Narrative
# --------
# Creating datetime from unix timestamp
#
# Extracted from stzdatetimetest.ring, block #7.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ(1710498600) # March 15, 2024, 10:30:00 UTC
? oDateTime.Content()
#--> 2024-03-15 10:30:00

? oDateTime.ToUnixTimeStamp()
#--> 1710498600

pf()
# Executed in almost 0 second(s) in Ring 1.23
