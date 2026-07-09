# Narrative
# --------
# Growing a list to a fixed length by cycling its existing items.
#
# ExtendXT( :ToPosition = 5, :ByItemsRepeated ) enlarges the list until
# it reaches position 5, filling the new slots by repeating the original
# items in order. Starting from [ "A", "B", "C" ], the two extra slots
# are filled with "A" then "B", giving [ "A", "B", "C", "A", "B" ]. The
# :ByItemsRepeated mode is the Softanza idiom for padding a list with a
# cyclic copy of itself rather than a single constant value.
#
# Extracted from stzlisttest.ring, block #159.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Growing a list to a fixed length by cycling its existing items.")

	o1 = new stzList([ "A", "B", "C" ])
	o1.ExtendXT( :ToPosition = 5, :ByItemsRepeated )
	// ByItemsRepeated

	Then("extendxt example 1", @@( o1.Content() ), @@( [ "A", "B", "C", "A", "B" ] ))
EndScenario()

Summary()
