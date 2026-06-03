# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #729.
#ERR Error (R14) : Calling Method without definition: replacenthcharq

load "../../stzBase.ring"

pr()

? StzStringQ("évènement").ReplaceNthCharQ(3, "*").Content()
#--> év*nement

? StzStringQ("évènement").ReplaceNthCharQ(3, :With = "*").Content()
#--> év*nement

pf()
# Executed in 0.01 second(s).
