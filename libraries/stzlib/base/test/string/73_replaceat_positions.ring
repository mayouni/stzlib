load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAt(positions, sub, :By = new) -- the plain-spelling twin of block #72:
# replace `sub` where it starts at each listed position. Archive block #73.

Scenario("Replacing a substring at several positions")
	Given('"ring ruby ring php ring" (rings at 1, 11, 20)')
	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceAt([ 1, 20 ], "ring", :By = "♥♥♥")
	Then("the rings at 1 and 20 change; the one at 11 stays",
		o1.Content(), "♥♥♥ ruby ring php ♥♥♥")
EndScenario()

Summary()
