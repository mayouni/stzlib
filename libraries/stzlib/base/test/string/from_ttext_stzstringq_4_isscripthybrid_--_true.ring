# Narrative
# --------
# ? StzStringQ(" 4  ُ  ").IsScript(:Hybrid) #--> TRUE
#
# Extracted from stzTtexttest.ring, block #11.
#ERR Error (R14) : Calling Method without definition: isscript

load "../../stzBase.ring"

pr()

? StzStringQ("  ").IsScript(:Common) #--> TRUE
? StzStringQ(ArabicDhammah()).IsScript(:Inherited) #--> TRUE

pf()
