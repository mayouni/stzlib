# Narrative
# --------
# Duration (object param)
#
# Extracted from stzdatetimetest.ring, block #18.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")
oDateTime2 = StzDateTimeQ("2024-03-20 14:30:15")
? oDateTime1.DurationTo(oDateTime2, :In = :Days)
#--> 5

pf()
# Executed in 0.01 second(s) in Ring 1.24
