# Narrative
# --------
# ? StzStringQ(" 4  ُ  ").IsScriptOf(:Hybrid) #--> TRUE
#
# Extracted from stzTtexttest.ring, block #11.

load "../../stzBase.ring"

pr()

? StzStringQ("  ").IsScriptOf(:Common) #--> TRUE
? StzStringQ(ArabicDhammah()).IsScriptOf(:Inherited) #--> TRUE

pf()
