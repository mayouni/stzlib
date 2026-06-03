# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #496.
#ERR Error (R14) : Calling Method without definition: @

load "../../stzBase.ring"

pr()

o1 = new stzString("__Ri__ng__")

o1.@("__").@Remove()
? o1.content()
#--> Ring

pf()
# Executed in 0.05 second(s) in Ring 1.22
