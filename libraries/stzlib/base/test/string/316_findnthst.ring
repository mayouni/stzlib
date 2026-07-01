load "../../stzBase.ring"
load "../_narrated.ring"

# The ST (starting-at) forms look FORWARD from :StartingAt; FindPrevious
# looks strictly backward -- only occurrences lying entirely before the
# starting position count. Archive block #316.

Scenario("Starting-at finders")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the 1st from position 3 is 3 itself",
		o1.FindNthST(1, "♥♥♥", :StartingAt = 3), 3)
	Then("the next after 3", o1.FindNext("♥♥♥", :StartingAt = 3), 8)
	Then("the previous before 10 must END before 10",
		o1.FindPrevious("♥♥♥", :StartingAt = 10), 3)
EndScenario()

Summary()
