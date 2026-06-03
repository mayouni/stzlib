# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #279.
#ERR Error (R14) : Calling Method without definition: updatewith

load "../../stzBase.ring"

pr()

o1 = new stzString("999999999999")
o1.UpdateWith("999 999 999.999")
? o1.Content()

pf()
# Executed in 0.01 second(s).
