# Narrative
# --------
# Example 2: From epoch days
#
# Extracted from stzdatetimetest.ring, block #63.

load "../../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :FromEpochDays = 20000 ])
? oDateTime.ToStringXT(:Standard)
#--> 04/10/2024 01:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
