# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #716.
#ERR Error (R3) : Calling Function without definition: tq

load "../../stzBase.ring"

pr()

# TQ is an abbreviation of StzTextQ()

? TQ("عربي").Script()
#--> arabic

? TQ("ring").Script()
#--> latin

pf()
# Executed in 0.06 second(s).
