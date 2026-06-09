# Narrative
# --------
# Morning times (AM)
#
# Extracted from stzdatetimetest.ring, block #53.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oMorning = StzDateTimeQ("2024-03-15 09:15:30")

? oMorning.ToCompact()
#--> 2024-03-15 9:15 AM

? oMorning.ToCompact12h()
#--> 2024-03-15 9:15 AM

? oMorning.ToCompact24h()
#--> 2024-03-15 09:15

pf()
# Executed in 0.01 second(s) in Ring 1.23
