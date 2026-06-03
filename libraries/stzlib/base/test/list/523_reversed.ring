# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #523.
#ERR Error (R14) : Calling Method without definition: itemsreversed

load "../../stzBase.ring"

pr()

? @@( StzListQ("A":"E").Reversed() )
#--> [ "E", "D", "C", "B", "A" ]

? @@( StzListQ("A":"E").ItemsReversed() )
#--> [ "E", "D", "C", "B", "A" ]

pf()
# Executed in almost 0 second(s).
