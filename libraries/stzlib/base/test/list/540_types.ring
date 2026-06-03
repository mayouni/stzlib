# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #540.
#ERR Error (R14) : Calling Method without definition: types

load "../../stzBase.ring"

pr()

? @@( StzListQ([ "a", 1, "b", 2, "c", 3 ]).Types() ) + NL
#--> [ "STRING", "NUMBER", "STRING", "NUMBER", "STRING", "NUMBER" ]

? StzListQ([ "a", 1, "b", 2, "c", 3 ]).UniqueTypes()
#--> [ "STRING", "NUMBER" ]

pf()
# Executed in almost 0 second(s).
