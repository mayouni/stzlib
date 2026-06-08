# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #498.
#ERR exit 1: Error (S1) In file: 498_content.ring

load "../../stzBase.ring"

pr()

o1 = new stzString("__Ri__ng__")

o1.@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheString()

? o1.Content()
#--> RING

pf()
