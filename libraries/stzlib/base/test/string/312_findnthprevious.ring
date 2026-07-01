load "../../stzBase.ring"
load "../_narrated.ring"

# FindNthPrevious counts occurrences BACKWARD from :StartingAt (only ones
# lying entirely before it): the :First previous is the nearest, the :Last
# previous the farthest. Archive block #312.

Scenario("Nth previous occurrence going backward")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the last previous from 12 is the farthest",
		o1.FindNthPrevious(:Last, "♥♥♥", :StartingAt = 12), 3)
	Then("the first previous from 12 is the nearest",
		o1.FindNthPrevious(:First, "♥♥♥", :StartingAt = 12), 8)
EndScenario()

Summary()
