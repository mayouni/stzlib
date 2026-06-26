load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveAt(positions, sub) -- remove the occurrences of `sub` starting at each of
# the listed positions in one call (codepoint-aware). Archive block #69.

Scenario("Removing a substring at several positions")
	Given('"♥♥♥ring ♥♥♥ruby ♥♥♥php" (hearts at 1, 9, 17)')
	o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
	o1.RemoveAt([ 1, 9, 17 ], "♥♥♥")
	Then("all three heart runs are gone", o1.Content(), "ring ruby php")
EndScenario()

Summary()
