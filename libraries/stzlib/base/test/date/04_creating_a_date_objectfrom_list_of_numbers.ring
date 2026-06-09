# Narrative
# --------
# Creating a date objectfrom list of numbers
#
# Extracted from stzdatetest.ring, block #4.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

o1 = new stzDate([ 2024, 10, 10 ])
? o1.Date()
#--> 10/10/2024

pf()
# Executed in almost 0 second(s) in Ring 1.23
