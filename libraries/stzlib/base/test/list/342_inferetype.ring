# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #342.
#ERR Error (R14) : Calling Method without definition: inferetype

load "../../stzBase.ring"

pr()

? InfereType("string")
#--> string

? InfereType("strings")
#--> strings

pf()
# Executed in 0.01 second(s).
