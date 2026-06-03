# Narrative
# --------
# Default 24-hour behavior
#
# Extracted from stzdatetimetest.ring, block #41.

load "../../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToString()
#--> 2024-03-15 14:30:45

? oDateTime.ToStringXT("")
#--> 2024-03-15 14:30:45 (uses $cDefaultDateTimeFormat)

? oDateTime.ToStringXT("yyyy-MM-dd HH:mm:ss")
#--> 2024-03-15 14:30:45

? oDateTime.ToEuropean()
#--> 15/03/2024 2:30:45 PM

? oDateTime.ToAmerican()
#--> 03/15/2024 2:30:45 PM

pf()
# Executed in 0.01 second(s) in Ring 1.24
