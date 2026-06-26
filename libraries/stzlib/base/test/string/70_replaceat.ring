load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAt(pos, sub, :By = new) -- replace the occurrence of `sub` starting at
# character position `pos` with `new`. Archive block #70.

Scenario("Replacing a substring at a known position")
	Given('"ruby ring php" (ring starts at position 6)')
	o1 = new stzString("ruby ring php")
	o1.ReplaceAt(6, "ring", :By = "♥♥♥")
	Then("the ring at position 6 becomes hearts", o1.Content(), "ruby ♥♥♥ php")
EndScenario()

Summary()
