# Narrative
# --------
# Creating datetime from European format
#
# Extracted from stzdatetimetest.ring, block #3.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:30:00")
? oDateTime.Content()
#--> 2024-03-15 10:30:00

? oDateTime.ToEuropean() # Or ToEuropeanAmPm() or ToEuropean12h()
#--> 15/03/2024 10:30:00 AM

# Or you can say
? oDateTime.ToEuropeanWithoutAmPm() # Or ToEuropean24h()
#--> 15/03/2024 10:30:00

pf()
# Executed in 0.01 second(s) in Ring 1.24
