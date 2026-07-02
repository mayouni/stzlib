load "../../stzBase.ring"
load "../_narrated.ring"

# The plain ST (starting-at) position finders, forward from position 6.
# Archive block #323.

Scenario("First / last / nth from a starting position")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the first from 6", o1.FindFirstST("♥♥♥", :StartingAt = 6), 8)
	Then("the last from 6", o1.FindLastST("♥♥♥", :StartingAt = 6), 13)
	Then("the 2nd from 6", o1.FindNthST(2, "♥♥♥", :StartingAt = 6), 13)
EndScenario()

Summary()
