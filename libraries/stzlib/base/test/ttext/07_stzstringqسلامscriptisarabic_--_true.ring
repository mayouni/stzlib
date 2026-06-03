# Narrative
# --------
# ? StzStringQ("سلام").ScriptIs(:Arabic) #--> TRUE
#
# Extracted from stzTtexttest.ring, block #7.

load "../../stzBase.ring"

? StzStringQ("Peace").ScriptIs(:Latin) #--> TRUE
? StzStringQ("和平").ScriptIs(:Han) #--> TRUE (China)
? StzStringQ("શાંતિ").ScriptIs(:Gujarati) #--> TRUE (India, Pakistan)
