# Narrative
# --------
# Example 1: From epoch seconds
#
# Extracted from stzdatetimetest.ring, block #62.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :FromEpochSeconds = 1609459200 ])
? oDateTime.ToString()
#--> 2021-01-01 00:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
