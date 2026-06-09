# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #498.
#ERR Error (R14) : Calling Method without definition: @

load "../../stzBase.ring"

pr()

o1 = new stzString("__Ri__ng__")

o1.@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheString()

? o1.Content()
#--> RING

pf()
