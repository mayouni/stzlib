# Narrative
# --------
# Converting to UTC and local time
#
# Extracted from stzdatetimetest.ring, block #26.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToUTC()
#--> 2024-03-15 13:30:45 (depends on timezone)

? oDateTime.ToLocalTime()
#--> 2024-03-15 14:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23
