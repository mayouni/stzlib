# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #79.

load "../../stzBase.ring"


o1 = new stzString("--Ring--__Softanza__")
o1.ReplaceAllExcept([ "Ring", "&", "Softanza" ], :With = AHeart())
? o1.Content()
#--> Ring&♥Ring♥Softanza♥

pf()
# Executed in 0.11 second(s)
