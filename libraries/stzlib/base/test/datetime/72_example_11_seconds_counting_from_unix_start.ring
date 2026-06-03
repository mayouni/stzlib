# Narrative
# --------
# Example 11 : Seconds counting from Unix start
#
# Extracted from stzdatetimetest.ring, block #72.

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :CountingFromUnixStart = 1609459200 ])
? oDateTime.ToCompact()
#--> 2021-01-01 01:00 AM

pf()
# Executed in 0.01 second(s) in Ring 1.24
