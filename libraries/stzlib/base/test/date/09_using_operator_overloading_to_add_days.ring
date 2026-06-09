# Narrative
# --------
# Using operator overloading to add days
#
# Extracted from stzdatetest.ring, block #9.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDate = StzDateQ("01/01/2025")
? oDate + 15
#--> 16/01/2025

pf()
# Executed in almost 0 second(s) in Ring 1.23
