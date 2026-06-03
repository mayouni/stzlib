# Narrative
# --------
# Example 6: Complex natural language (auto-detected - must include "from epoch")
#
# Extracted from stzdatetimetest.ring, block #67.

load "../../../stzBase.ring"


pr()

oDateTime = new stzDateTime("5 years 3 months 20 days 8 hours 45 minutes 30 seconds from epoch")
? oDateTime.ToStringXT(:ISO8601)
#--> 1980-08-09T07:16:30

pf()
# Executed in 0.02 second(s) in Ring 1.24
