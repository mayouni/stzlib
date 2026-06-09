# Narrative
# --------
# Example 12: Duration counting from specific origin
#
# Extracted from stzdatetimetest.ring, block #73.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([
    :CountingFrom = [ :Origin = :UnixStart, :Years = 50, :Days = 100 ]
])

? oDateTime.Content()
#--> 2020-03-29 01:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
