# Narrative
# --------
# ? StzStringQ("سلام").ScriptIs(:Arabic) #--> TRUE
#
# Extracted from stzTtexttest.ring, block #7.
#ERR exit 3221225794

load "../../stzBase.ring"

pr()

? StzStringQ("Peace").ScriptIs(:Latin) #--> TRUE
? StzStringQ("和平").ScriptIs(:Han) #--> TRUE (China)
? StzStringQ("શાંતિ").ScriptIs(:Gujarati) #--> TRUE (India, Pakistan)

pf()
