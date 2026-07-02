load "../../stzBase.ring"
load "../_narrated.ring"

# The ST position finders when only ONE occurrence lies at/after the
# starting position -- first, last and 2nd-from-3 all land on 22.
# Archive block #351.

Scenario("Starting-at finders converging on the last occurrence")
	Given('"bla {♥♥♥} blaba bla {♥♥♥} blabla" (hearts at 6, 22)')
	o1 = new stzString("bla {♥♥♥} blaba bla {♥♥♥} blabla")
	Then("the first from 8", o1.FindFirstST("♥♥♥", :StartingAt = 8), 22)
	Then("the last from 8", o1.FindLastST("♥♥♥", :Startingat = 8), 22)
	Then("the 2nd from 3", o1.FindNthST(2, "♥♥♥", :StartingAt = 3), 22)
EndScenario()

Summary()
