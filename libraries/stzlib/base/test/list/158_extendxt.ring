# Narrative
# --------
# Growing a list up to a target length with ExtendXT(:List, :ToPosition).
#
# Starting from [ "A", "B", "C" ], ExtendXT( :List, :ToPosition = 5 )
# stretches the list so its last index becomes position 5. The two
# new slots (positions 4 and 5) are filled with empty strings rather
# than a chosen value, so a list is padded out to a known size while
# preserving the original head untouched.
#
# Extracted from stzlisttest.ring, block #158.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Growing a list up to a target length with ExtendXT(:List, :ToPosition).")

	o1 = new stzList([ "A", "B", "C" ])
	o1.ExtendXT( :List, :ToPosition = 5 )
	Then("extendxt example 1", @@( o1.Content() ), @@( [ "A", "B", "C", "", "" ] ))
EndScenario()

Summary()
