# Narrative
# --------
# Subtracting days using operator
#
# Extracted from stzdatetest.ring, block #11.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDate = StzDateQ("20/12/2024")
? oDate - 10
#--> 10/12/2024

pf()
# Executed in almost 0 second(s) in Ring 1.23
