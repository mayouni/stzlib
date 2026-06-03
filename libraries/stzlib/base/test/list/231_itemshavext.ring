# Narrative
# --------
# StartProfiler()
#
# Extracted from stzlisttest.ring, block #231.
#ERR Error (R14) : Calling Method without definition: itemshavext

load "../../stzBase.ring"

pr()

? Q([ "ONE", "ONE", "ONE" ]).ItemsHaveXT('{ len(@item) = 3 }')
#--> TRUE

? Q([ "One", "Two", "Three" ]).Are(:Strings)
#--> TRUE

? Q(1:5).ItemsAre(:Numbers)
#--> TRUE

? Q([ "A":"C", "D":"F", "G":"I" ]).ItemsAre(:Lists)
#--> TRUE

? Q([ "A":"C", "D":"F", "G":"I" ]).ItemsAre(:ListsOfStrings)
#--> TRUE

StopProfiler()

pf()
# Executed in 0.24 second(s) in Ring 1.19
# Executed in 0.47 second(s) in Ring 1.19
