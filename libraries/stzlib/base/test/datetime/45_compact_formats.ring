# Narrative
# --------
# Compact formats
#
# Extracted from stzdatetimetest.ring, block #45.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToCompact()
 #--> 2024-03-15 2:30 PM

? oDateTime.ToStringXT(:CompactSec)
#--> 2024-03-15 14:30:45

pf()
# Executed in 0.01 second(s) in Ring 1.24
