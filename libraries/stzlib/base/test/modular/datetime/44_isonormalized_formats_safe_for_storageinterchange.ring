# Narrative
# --------
# ISO/Normalized formats (safe for storage/interchange)
#
# Extracted from stzdatetimetest.ring, block #44.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToISO()
#--> 2024-03-15 14:30:45

? oDateTime.ToIso8601()
#--> 2024-03-15T14:30:45

? oDateTime.ToIsoWithMs()
#--> 2024-03-15 14:30:45.000

pf()
# Executed in almost 0 second(s) in Ring 1.23
