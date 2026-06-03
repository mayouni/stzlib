# Narrative
# --------
# Creating datetime from American format
#
# Extracted from stzdatetimetest.ring, block #4.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:30:00")
? oDateTime.Content()
#--> 2024-03-15 10:30:00

? oDateTime.ToAmerican()
#--> 03/15/2024 10:30:00 AM

pf()
# Executed in almost 0 second(s) in Ring 1.23
