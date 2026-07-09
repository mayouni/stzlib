# Narrative
# --------
# ExtendXT() grows a list up to a target position, padding the gap with a filler value.
#
# Starting from [ "A", "B", "C" ] (length 3), ExtendXT( :ToPosition = 5, :With = "*" )
# stretches the list so position 5 exists, filling the two new slots (4 and 5) with "*".
# The XT ("extended") variant takes named options -- :ToPosition for the absolute target
# index and :With for the value to repeat into the new tail -- so the intent reads in plain
# Softanza prose. Existing items are untouched; only the appended slots receive the filler.
#
# Extracted from stzlisttest.ring, block #160.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("ExtendXT() grows a list up to a target position, padding the gap with a filler value.")

	o1 = new stzList([ "A", "B", "C" ])
	o1.ExtendXT( :ToPosition = 5, :With = "*" )
	Then("extendxt example 1", @@( o1.Content() ), @@( [ "A", "B", "C", "*", "*" ] ))
EndScenario()

Summary()
