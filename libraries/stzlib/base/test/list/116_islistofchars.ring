# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #116.
#ERR Error (R14) : Calling Method without definition: islistofchars

load "../../stzBase.ring"

pr()

? Q([ "a", "b", "c" ]).IsListOfChars()
#--> TRUE

? Q([ 1, 2, 3 ]).IsListOfChars()
#--> TRUE

pf()
# Executed in 0.01 second(s) in Ring 1.21
