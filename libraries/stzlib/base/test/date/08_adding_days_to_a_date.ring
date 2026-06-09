# Narrative
# --------
# Adding days to a date
#
# Extracted from stzdatetest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDate = StzDateQ("01/01/2025")
oDate.AddDays(30)
? oDate.Date()
#--> 31/01/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23
