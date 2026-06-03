# Narrative
# --------
# Using operator overloading for addition
#
# Extracted from stzdatetimetest.ring, block #13.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")

oDateTime + "2 days"
? oDateTime.Content()
#--> 2024-03-17 10:00:00

oDateTime + "3 hours"
? oDateTime.Content()
#--> 2024-03-17 13:00:00

oDateTime + "2 days 5 hours"
? oDateTime.Content()
#--> 2024-03-19 18:00:00

pf()
# Executed in 0.02 second(s) in Ring 1.24
