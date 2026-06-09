# Narrative
# --------
# Example 5: From epoch weeks
#
# Extracted from stzdatetimetest.ring, block #66.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :FromEpochWeeks = 2857 ])
? oDateTime.ToStringXT(:Compact)
#--> 2024-10-03 01:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
