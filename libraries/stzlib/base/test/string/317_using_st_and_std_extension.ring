load "../../stzBase.ring"
load "../_narrated.ring"

# The ..ST() (starting-at) and ..STD() (starting-at + direction) extensions.
# Forward looks at occurrences starting at/after :StartingAt; :Backward
# looks at occurrences ENDING at/before it -- the "first" backward hit is
# the nearest one, the "last" the farthest. Archive block #317.

Scenario("ST forms look forward from a position")
	Given('"12♥♥♥67♥♥♥12♥♥♥" (occurrences at 3, 8, 13)')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the 2nd from 3", o1.FindNthST(2, "♥♥♥", :StartingAt = 3), 8)
	Then("the first from 5", o1.FindFirstST("♥♥♥", :StartingAt = 5), 8)
	Then("the last from 6", o1.FindLastST("♥♥♥", :StartingAt = 6), 13)
EndScenario()

Scenario("STD forms add a direction")
	Given('the same string')
	o1 = new stzString("12♥♥♥67♥♥♥12♥♥♥")
	Then("the 2nd backward from 10 (:Going spelling)",
		o1.FindNthSTD(2, "♥♥♥", :StartingAt = 10, :Going = :Backward), 3)
	Then("the first backward from 14 (bare :Backward)",
		o1.FindFirstSTD("♥♥♥", :StartingAt = 14, :Backward), 8)
	Then("the last backward from 6 (:Direction spelling)",
		o1.FindLastSTD("♥♥♥", :StartingAt = 6, :Direction = :Backward), 3)
EndScenario()

Summary()
