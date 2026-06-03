# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #497.
#ERR Error (R14) : Calling Method without definition: @

load "../../stzBase.ring"

pr()

o1 = new stzString("__Ri__ng__")
? o1.@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheString()
#--> RING

# Which we can write in even more elegant  form (without o1, and using an alternative of @() called @Take())

? Q("__Ri__ng__").@Take("__").@RemoveItQ().AndThenQ().UppercaseQ().TheString()
#--> RING

pf()
# Executed in 0.06 second(s) in Ring 1.22
