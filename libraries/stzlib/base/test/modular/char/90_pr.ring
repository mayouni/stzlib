# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #90.

load "../../../stzBase.ring"


? ShowShort( LanguagesInScript(CharScript("ض")) ) + NL
#--> [ "acehnese", "adyghe", "afar", "...", "wolof", "yoruba", "zarma" ]

? ShowShort( StzScriptQ(CharScript("ض")).Languages() )
#--> [ "acehnese", "adyghe", "afar", "...", "wolof", "yoruba", "zarma" ]

pf()
# Executed in 0.01 second(s) in Ring 1.23
