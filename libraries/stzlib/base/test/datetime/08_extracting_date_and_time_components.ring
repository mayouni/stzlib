# Narrative
# --------
# Extracting date and time components
#
# Extracted from stzdatetimetest.ring, block #8.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15 14:30:45")

? oDateTime.Date()
#--> 2024-03-15

? oDateTime.DateQ().Content() + NL
#--> 15/03/2024

? oDateTime.Time()
#--> 14:30:45

? oDateTime.TimeQ().Content()
#--> 14:30:45

pf()
# Executed in 0.01 second(s) in Ring 1.23
