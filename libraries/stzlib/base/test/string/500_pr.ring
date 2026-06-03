# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #500.

load "../../stzBase.ring"

pr()

? Q("__Ri__ng__").
	@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyItR()

#--> R I N G

? Q("__Ri__ng__").
	@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyItQ().AsWell()
#--> R I N G

? Q("__Ri__ng__").
	@("__").@RemoveItQ().AndThenQ().UppercaseQ().TheStringQ().AndQ().SpacifyItQ().@0(:AsWell)
#--> R I N G

pf()
# Executed in 0.06 second(s) in Ring 1.22
