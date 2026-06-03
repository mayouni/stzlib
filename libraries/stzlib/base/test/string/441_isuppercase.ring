# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #441.
#ERR Error (R14) : Calling Method without definition: isatcharsnamedparam

load "../../stzBase.ring"

pr()

? Q([ "atchars", "Q(@char).IsUppercase()" ]).IsAtCharsNamedParam()
#--> TRUE

pf()
