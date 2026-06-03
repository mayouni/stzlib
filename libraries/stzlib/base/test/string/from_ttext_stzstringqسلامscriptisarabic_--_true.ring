# Narrative
# --------
# ? StzStringQ("سلام").ScriptIs(:Arabic) #--> TRUE
#
# Extracted from stzTtexttest.ring, block #7.
#ERR Error (E9) : Can't open file from_ttext_stzstringq????scriptisarabic_--_true.ring

load "../../stzBase.ring"

pr()

? StzStringQ("Peace").ScriptIs(:Latin) #--> TRUE
? StzStringQ("和平").ScriptIs(:Han) #--> TRUE (China)
? StzStringQ("શાંતિ").ScriptIs(:Gujarati) #--> TRUE (India, Pakistan)

pf()
