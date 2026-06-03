# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #889.
#ERR Error (R14) : Calling Method without definition: removesubstringboundedby

load "../../stzBase.ring"

pr()

o1 = new stzString("__^^^__^^♥^^__")
o1.RemoveSubStringBoundedBy("♥", "^^")
? o1.Content()
#--> __^^^__^^^^__

pf()
# Executed in 0.03 second(s).
