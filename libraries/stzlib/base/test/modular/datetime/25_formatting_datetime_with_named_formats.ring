# Narrative
# --------
# Formatting datetime with named formats
#
# Extracted from stzdatetimetest.ring, block #25.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStringXT(:Standard)
#--> 2024-03-15 14:30:45

? oDateTime.ToStringXT(:Short)
#--> 15/03 2:30 PM

? oDateTime.ToStringXT(:ISO8601)
#--> 2024-03-15T14:30:45

? oDateTime.ToStringXT(:Long)
#--> Friday, March 15, 2024 2:30:45 PM

pf()
# Executed in 0.01 second(s) in Ring 1.24
