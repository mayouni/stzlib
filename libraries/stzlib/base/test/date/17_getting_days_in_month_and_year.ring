# Narrative
# --------
# Getting days in month and year
#
# Extracted from stzdatetest.ring, block #17.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDate = StzDateQ("15/02/2024")

? oDate.DaysInMonth()
#--> 29

? oDate.DaysInYear()
#--> 366

pf()
# Executed in almost 0 second(s) in Ring 1.23
