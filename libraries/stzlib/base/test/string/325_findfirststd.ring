load "../../stzBase.ring"
load "../_narrated.ring"

# The STD position finders going :Backward from position 12 -- candidates
# are the occurrences ending at/before 12; first = nearest, last = farthest.
# Archive block #325.

Scenario("Backward STD positions")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the first backward from 12",
		o1.FindFirstSTD("♥♥♥", :StartingAt = 12, :Backward), 8)
	Then("the last backward from 12",
		o1.FindLastSTD("♥♥♥", :StartingAt = 12, :Backward), 3)
	Then("the 2nd backward from 12",
		o1.FindNthSTD(2, "♥♥♥", :StartingAt = 12, :Backward), 3)
EndScenario()

Summary()
