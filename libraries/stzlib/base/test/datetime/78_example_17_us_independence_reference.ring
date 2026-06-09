# Narrative
# --------
# Example 17: US Independence reference
#
# Extracted from stzdatetimetest.ring, block #78.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDateTime = new stzDateTime([
    :CountingFromUSIndependence = [ :Years = 248, :Months = 3 ]
])

? oDateTime.Content()
#--> 2024-08-04 07:00:00

pf()
# Executed in almost 0 second(s) in Ring 1.24
