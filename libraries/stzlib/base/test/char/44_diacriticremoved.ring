# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #44.
#ERR Error (R14) : Calling Method without definition: diacriticremoved

load "../../stzBase.ring"

pr()

? StzCharQ("é").DiacriticRemoved() #--> e
? StzCharQ("Ŵ").DiacriticRemoved() #--> W
? StzCharQ("ſ").DiacriticRemoved() #--> s

pf()
# Executed in 0.03 second(s) in Ring 1.23
