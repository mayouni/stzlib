# Narrative
# --------
# Using operator overloading for subtraction
#
# Extracted from stzdatetimetest.ring, block #14.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime - "2 days"
? oDateTime.Content()
#--> 2024-03-13 10:00:00

oDateTime - "3 hours"
? oDateTime.Content()
#--> 2024-03-13 07:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.23
