# Narrative
# --------
# Using comparison methods (object param)
#
# Extracted from stzdatetimetest.ring, block #22.

load "../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime2 = StzDateTimeQ("2024-03-20 10:00:00")

? oDateTime1.IsBefore(oDateTime2)
#--> TRUE

? oDateTime1.IsAfter(oDateTime2)
#--> FALSE

? oDateTime1.IsEqualTo(oDateTime1)
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.24
