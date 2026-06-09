# Narrative
# --------
# Example 3: Natural language string (auto-detected - must include "from epoch")
#
# Extracted from stzdatetimetest.ring, block #64.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime("54 years 9 months 3 days from epoch")
? oDateTime.ToVerbose()
#--> Sunday, July 11, 2079 13:00:00 PM

pf()
# Executed in almost 0 second(s) in Ring 1.24
