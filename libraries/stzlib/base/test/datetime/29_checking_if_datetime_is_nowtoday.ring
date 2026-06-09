# Narrative
# --------
# Checking if datetime is now/today
#
# Extracted from stzdatetimetest.ring, block #29.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oNow = StzDateTimeQ("")
? oNow.IsNow()
#--> TRUE

? oNow.IsToday()
#--> TRUE

pf()
# Executed in almost 0 second(s) in Ring 1.24
