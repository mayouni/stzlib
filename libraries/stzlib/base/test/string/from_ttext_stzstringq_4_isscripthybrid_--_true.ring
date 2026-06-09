# Narrative
# --------
# ? StzStringQ(" 4  ُ  ").IsScriptOf(:Hybrid) #--> TRUE
#
# Extracted from stzTtexttest.ring, block #11.
#ERR Error (R20) : Calling function with extra number of parameters

load "../../stzBase.ring"

pr()

? StzStringQ("  ").IsScriptOf(:Common) #--> TRUE
? StzStringQ(ArabicDhammah()).IsScriptOf(:Inherited) #--> TRUE

pf()
