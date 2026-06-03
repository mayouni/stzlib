# Narrative
# --------
# Human-readable datetime
#
# Extracted from stzdatetimetest.ring, block #27.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")
? oDateTime.ToHuman()
#--> Friday, March 3rd, 2024 at Half past 2 PM

pf()
# Executed in 0.01 second(s) in Ring 1.24
