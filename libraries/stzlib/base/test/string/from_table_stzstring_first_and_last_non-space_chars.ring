load "../../stzBase.ring"
load "../_narrated.ring"

# The first and last non-space chars, and their positions.
# Extracted from stztabletest.ring, block #9.

Scenario("The real edges of a padded string")
	o1 = new stzString("   RING  ")
	Then("first non-space char", o1.FirstNonSpaceChar(), "R")
	Then("... at position 4", o1.FindFirstNonSpaceChar(), 4)
	Then("last non-space char", o1.LastNonSpaceChar(), "G")
	Then("... at position 7", o1.FindLastNonSpaceChar(), 7)
EndScenario()

Summary()
