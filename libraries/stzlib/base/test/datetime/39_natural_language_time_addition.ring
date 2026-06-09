# Narrative
# --------
# Natural language time addition
#
# Extracted from stzdatetimetest.ring, block #39.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")
? oDateTime.Hours()
#--> 10

oDateTime.AddNatural("2 days 3 hours 30 minutes 28 seconds 540 milliseconds")
? oDateTime.ToStringXT("yyyy-mm-dd hh-mm-ss.zzz")
#--> 2024-30-17 13-30-28.540

pf()
# Executed in 0.01 second(s) in Ring 1.24
