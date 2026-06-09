# Narrative
# --------
# Example 10: From epoch years
#
# Extracted from stzdatetimetest.ring, block #71.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :FromEpochYears = 55 ])
? oDateTime.ToLong()
#--> Wednesday, January 1, 2025 12:00:00 AM

? oDateTime.ToLongDate()
#--> Wednesday, January 1, 2025

pf()
# Executed in 0.01 second(s) in Ring 1.24
