# Narrative
# --------
# Chaining operations with Q methods
#
# Extracted from stzdatetimetest.ring, block #33.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 10:00:00")

? oDateTime.AddDaysQ(5).AddHoursQ(3).AddMinutesQ(30).ToString()
#--> 2024-03-20 13:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
