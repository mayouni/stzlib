# Narrative
# --------
# ? StzStringQ(" 4  ُ  ").IsScript(:Hybrid) #--> TRUE
#
# Extracted from stzTtexttest.ring, block #11.

load "../../stzBase.ring"

? StzStringQ("  ").IsScript(:Common) #--> TRUE
? StzStringQ(ArabicDhammah()).IsScript(:Inherited) #--> TRUE
