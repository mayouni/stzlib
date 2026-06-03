# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #471.
#ERR Error (R14) : Calling Method without definition: isafunction

load "../../stzBase.ring"

pr()

? Q("stzLen").IsAFunction() # or isFunc()
#--> TRUE

? Q("stzChar").IsAClass()
#--> TRUE

pf()
# Executed in 0.01 second(s).
