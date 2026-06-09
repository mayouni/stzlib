# Narrative
# --------
# pr()
#
# Extracted from stzfastprotest.ring, block #5.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

myList = 1:7

FastProUpdate(myList, :set = [ :all, :with = 5 ])
? @@(myList)
#--> [ 5, 5, 5, 5, 5, 5, 5 ]

pf()
# Executed in almost 0 second(s) in Ring 1.22
