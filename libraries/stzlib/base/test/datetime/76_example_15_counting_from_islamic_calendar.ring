# Narrative
# --------
# Example 15: Counting from Islamic calendar
#
# Extracted from stzdatetimetest.ring, block #76.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([
    :CountingFromIslamicCalendar = [ :Years = 1400 ]
])

? oDateTime.Content()
#--> 2021-08-13 01:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
