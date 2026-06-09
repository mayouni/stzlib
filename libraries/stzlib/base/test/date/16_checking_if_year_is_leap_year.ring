# Narrative
# --------
# Checking if year is leap year
#
# Extracted from stzdatetest.ring, block #16.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

? StzDateQ("15/02/2024").IsLeapYear()
#--> TRUE

? StzDateQ("15/02/2025").IsLeap()
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.23
