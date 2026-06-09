# Narrative
# --------
# Single digit hours
#
# Extracted from stzdatetimetest.ring, block #60.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oSingle = StzDateTimeQ("2024-03-15 03:05:00")

? oSingle.ToString12h()
#--> 2024-03-15 3:05:00 AM

? oSingle.ToStringXT("h:mm AP")
#--> 3:05 AM

pf()
# Executed in 0.01 second(s) in Ring 1.24
