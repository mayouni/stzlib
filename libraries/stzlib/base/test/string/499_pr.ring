# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #499.

load "../../stzBase.ring"


o1 = new stzString("__Ri__ng__")

o1.@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyIt()

? o1.Content()
#--> R I N G

pf()
# Executed in 0.06 second(s) in Ring 1.22
