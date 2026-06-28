# Narrative
# --------
# #expressiveness #elegant-code
# The elegant [ "Ring", :And = "Softanza" ] keep-list reads naturally and is
# honoured: both tokens are kept, each excluded run becomes one heart.
#
# Extracted from stzStringTest.ring, block #82.

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--__Softanza__")
o1.ReplaceAllExcept([ "Ring", :And = "Softanza" ], :With = AHeart())
? o1.Content()
#--> ♥Ring♥Softanza♥

pf()
