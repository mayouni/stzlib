# Narrative
# --------
# Hour boundaries
#
# Extracted from stzdatetimetest.ring, block #55.

load "../../../stzBase.ring"


pr()

oEleven = StzDateTimeQ("2024-03-15 11:59:59")
oOne = StzDateTimeQ("2024-03-15 13:00:00")

? oEleven.ToString12h()
#--> 2024-03-15 11:59:59 AM

? oOne.ToString12h()
#--> 2024-03-15 1:00:00 PM

pf()
# Executed in 0.01 second(s) in Ring 1.243
