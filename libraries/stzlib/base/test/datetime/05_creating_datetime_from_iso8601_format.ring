# Narrative
# --------
# Creating datetime from ISO8601 format
#
# Extracted from stzdatetimetest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ("2024-03-15T10:30:00")

? oDateTime.Content()
#--> 2024-03-15 10:30:00

? oDateTime.ToISO8601()
#--> 2024-03-15T10:30:00

pf()
# Executed in almost 0 second(s) in Ring 1.23
