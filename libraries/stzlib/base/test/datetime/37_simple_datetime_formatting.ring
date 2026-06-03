# Narrative
# --------
# Simple datetime formatting
#
# Extracted from stzdatetimetest.ring, block #37.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToSimple()
#--> 15/03/2024 2:30 PM

? oDateTime.ToLong()
#--> Friday, March 15, 2024 2:30:45 PM

pf()
# Executed in 0.01 second(s) in Ring 1.24
