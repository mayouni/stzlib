# Narrative
# --------
# Creating datetime from hash format
#
# Extracted from stzdatetimetest.ring, block #6.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = StzDateTimeQ([
    :Year = 2024,
    :Month = 3,
    :Day = 15,
    :Hour = 10,
    :Minute = 30,
    :Second = 45
])

? oDateTime.Content()
#--> 2024-03-15 10:30:45

pf()
# Executed in almost 0 second(s) in Ring 1.23
