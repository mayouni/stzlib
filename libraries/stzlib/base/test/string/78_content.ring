# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #78.
#ERR Error (R14) : Calling Method without definition: removeallexcept

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--&__Softanza__")
o1.RemoveAllExcept([ "Ring", "&", "Softanza" ])
? o1.Content()
#--> Ring&Softanza

pf()
