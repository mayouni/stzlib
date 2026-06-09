# Narrative
# --------
# Example 7: From epoch milliseconds
#
# Extracted from stzdatetimetest.ring, block #68.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :FromEpochMilliseconds = 1609459200500 ])
? oDateTime.ToStringXT(:ISOWithMs)
#--> 2021-01-01 01:00:00.500

pf()
# Executed in almost 0 second(s) in Ring 1.24
