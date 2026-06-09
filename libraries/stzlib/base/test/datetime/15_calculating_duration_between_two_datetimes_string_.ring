# Narrative
# --------
# Calculating duration between two datetimes (string param) #TODO #ERR
#
# Extracted from stzdatetimetest.ring, block #15.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime1 = StzDateTimeQ("2024-03-15 10:00:00")

? oDateTime1.ToString()
#--> 2024-03-15 10:00:00

? oDateTime1.DaysTo("2024-03-20 14:30:00")
#--> 5

? oDateTime1.HoursTo("2024-03-20 14:30:00")
#--> 124.5

? oDateTime1.MinutesTo("2024-03-20 14:30:00")
#--> 7470

? oDateTime1.SecsTo("2024-03-20 14:30:00")
#--> 448200

pf()
# Executed in 0.02 second(s) in Ring 1.24
