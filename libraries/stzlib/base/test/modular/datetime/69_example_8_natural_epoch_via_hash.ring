# Narrative
# --------
# Example 8: Natural epoch via hash
#
# Extracted from stzdatetimetest.ring, block #69.

load "../../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :FromNaturalEpoch = "2 years 6 months 15 days" ])
? oDateTime.ToStringXT(:European)
#--> 30/01/1975 01:00:00

pf()
# Executed in 0.01 second(s) in Ring 1.24
