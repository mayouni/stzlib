# Narrative
# --------
# Explicit 12-hour methods
#
# Extracted from stzdatetimetest.ring, block #43.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.ToSimple()
#--> 15/03/2024 2:30 PM

? oDateTime.ToLong() # Depends on your system locale language
#--> Friday, March 15, 2024 2:30:45 PM

? oDateTime.ToString12h()
#--> 2024-03-15 2:30:45 PM

? oDateTime.ToEuropean12h()
#--> 15/03/2024 2:30:45 PM

? oDateTime.ToAmerican12h()
#--> 03/15/2024 2:30:45 PM

pf()
# Executed in 0.02 second(s) in Ring 1.23
