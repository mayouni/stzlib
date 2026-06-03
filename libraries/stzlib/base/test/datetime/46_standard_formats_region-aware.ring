# Narrative
# --------
# Standard formats (region-aware)
#
# Extracted from stzdatetimetest.ring, block #46.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToStandard()
#--> 15/03/2024 2:30:45 PM

? oDateTime.ToEuropean()
#--> 15/03/2024 2:30:45 PM

? oDateTime.ToAmerican()
#--> 03/15/2024 2:30:45 PM

pf()
# Executed in 0.01 second(s) in Ring 1.243
