# Narrative
# --------
# ? StzStringQ(" 4  ُ  ").IsScript(:Hybrid) #--> TRUE
#
# Extracted from stzTtexttest.ring, block #11.
#ERR exit 3221225794

load "../../stzBase.ring"

pr()

? StzStringQ("  ").IsScript(:Common) #--> TRUE
? StzStringQ(ArabicDhammah()).IsScript(:Inherited) #--> TRUE

pf()
