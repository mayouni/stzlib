# Narrative
# --------
# Verbose formats
#
# Extracted from stzdatetimetest.ring, block #47.

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToVerbose() # Depends on your current system language
#--> Friday, March 15, 2024 2:30:45 PM

? oDateTime.ToVerbose24h()
#--> Friday, March 15, 2024 14:30:45

# 12-hour formats (automatic AM/PM)

? oDateTime.ToISO()
#--> 2024-03-15 02:30:45

? oDateTime.ToStandard12h()
#--> 15/03/2024 02:30:45 PM

? oDateTime.ToVerbose12h() # Depends on your current system language
#--> Friday, March 15, 2024 02:30:45 PM

pf()
# Executed in 0.01 second(s) in Ring 1.23
