# Narrative
# --------
# Locating and managing consecutive duplicate items (the "DupSecutive" family).
#
# A consecutive duplicate is an item that equals the one immediately before it.
# FindDupSecutiveItems() returns the positions of every such repeat occurrence,
# while DupSecutiveItemsZ() groups them per value as [ value, [ positions ] ].
# FindThisDupSecutiveItem(item) narrows the search to one value, and the *CS
# variants add a case-sensitivity dial: with :CS = FALSE, the lowercase "b"
# at position 5 joins the run of "B"s. RemoveDupSecutiveItemCS() then collapses
# such a case-insensitive run, keeping only the first member of each streak.
#
# Extracted from stzlisttest.ring, block #139.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Locating and managing consecutive duplicate items (the DupSecutive family).")

	# DupOrigins = DuplicatesOrigins

	o1 = new stzList([ "A", "B", "B", "B", "b", "C", "B", "C", "C", "c", "A" ])
	Then("finddupsecutiveitems example 1", @@( o1.FindDupSecutiveItems() ), @@( [ 3, 4, 9 ] ))

	Then("finddupsecutiveitems example 2", @@( o1.DupSecutiveItemsZ() ), @@( [ [ "B", [ 3, 4 ] ], [ "C", [ 9 ] ] ] ))

	Then("finddupsecutiveitems example 3", @@( o1.FindThisDupSecutiveItem("B") ), @@( [ 3, 4 ] ))

	Then("finddupsecutiveitems example 4", @@( o1.FindThisDupSecutiveItemCS("B", :CS = FALSE) ), @@( [ 3, 4, 5 ] ))

	Then("finddupsecutiveitems example 5", @@( o1.DupSecutiveItemCSZ("B", FALSE) ), @@( [ "B", [ 3, 4, 5 ] ] ))

	o1.RemoveDupSecutiveItemCS("B", FALSE)
	Then("finddupsecutiveitems example 6", @@( o1.Content() ), @@( [ "A", "B", "C", "B", "C", "C", "c", "A" ] ))
EndScenario()

Summary()
