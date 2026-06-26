load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSubstringAtPositions(positions, sub, :By = new) -- replace `sub` only
# where it starts at one of the listed positions; other occurrences are left
# alone. Archive block #61.

Scenario("Replacing a substring only at chosen positions")
	Given('"ring ruby ring php ring" (rings start at 1, 11, 20)')
	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceSubstringAtPositions([ 1, 20 ], "ring", :By = "♥♥♥")
	Then("only the rings at 1 and 20 change; the one at 11 stays",
		o1.Content(), "♥♥♥ ruby ring php ♥♥♥")
EndScenario()

Summary()
