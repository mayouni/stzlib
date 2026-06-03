# Narrative
# --------
# Example 9: From epoch hours
#
# Extracted from stzdatetimetest.ring, block #70.

load "../../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :FromEpochHours = 480000 ])
? oDateTime.ToStringXT(:American12h)
#--> 10/04/2024 1:00:00 AM

pf()
# Executed in 0.01 second(s) in Ring 1.24
