# Narrative
# --------
# MULTIPLE PARAMETER CONSUMPTION
#
# Extracted from stznaturaltest.ring, block #23.
#ERR Error (R14) : Calling Method without definition: findantisectionszz

load "../../stzBase.ring"


pr()

Naturally("
    Create a string with 'ONE two three'
    Replace 'two' with 'TWO'
    Replace 'three' with 'THREE' 
    Show it
")
#--> ONE TWO THREE

pf()
# Executed in 0.01 second(s) in Ring 1.24
