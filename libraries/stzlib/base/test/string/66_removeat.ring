load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveAt(pos, sub) -- remove the occurrence of `sub` that starts at character
# position `pos` (codepoint-aware, so the multibyte hearts are handled right).
# Archive block #66.

Scenario("Removing a substring at a known position")
	Given('"ring ♥♥♥ruby php" (hearts start at position 6)')
	o1 = new stzString("ring ♥♥♥ruby php")
	o1.RemoveAt(6, "♥♥♥")
	Then("the hearts at position 6 are gone", o1.Content(), "ring ruby php")
EndScenario()

Summary()
