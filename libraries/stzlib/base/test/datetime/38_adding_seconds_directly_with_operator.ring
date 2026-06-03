# Narrative
# --------
# Adding seconds directly with operator
#
# Extracted from stzdatetimetest.ring, block #38.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime + 3600 # Add 3600 seconds (1 hour)
? oDateTime.ToString()
#--> 2024-03-15 11:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
