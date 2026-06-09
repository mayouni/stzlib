# Narrative
# --------
# Example 14: Counting from Year One
#
# Extracted from stzdatetimetest.ring, block #75.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([ :CountingFromYearOne = 63_113_904_000 ])  # seconds
? oDateTime.Content()
#--> 2001-01-01 01:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
