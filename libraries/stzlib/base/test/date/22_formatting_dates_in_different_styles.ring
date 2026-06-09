# Narrative
# --------
# Formatting dates in different styles
#
# Extracted from stzdatetest.ring, block #22.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

oDate = StzDateQ("15/07/2024")

? oDate.ToEuropean()
#--> 15/07/2024

? oDate.ToAmerican()
#--> 07/15/2024

? oDate.ToISO8601()
#--> 2024-07-15

? oDate.ToStringXT("dddd, MMMM d, yyyy") # Custom format
#--> Monday, July 15, 2024

pf()
# Executed in almost 0 second(s) in Ring 1.23
