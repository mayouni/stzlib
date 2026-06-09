# Narrative
# --------
# pr()
#
# Extracted from stzGlobalTest.ring, block #2.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"

pr()

? 3 : 5
#--> [ 3, 5 ]

? "3" : "5"
#--> [ "3", "4", "5" ]

? 10 : 12
#--> [ 10, 11, 12 ]

? "10" : "12"
#--> "10"

? L(' "10":"12" ')
#--> #--> [ "10", "11", "12" ]

pf()
