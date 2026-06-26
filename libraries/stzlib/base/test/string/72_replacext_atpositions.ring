load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(sub, :AtPositions = list, :By = new) -- replace `sub` only where it
# starts at one of the listed character positions. (The plural :AtPositions form
# treats the values as absolute positions and works; the singular :AtPosition
# form is broken -- see _AUDIT_DEFECTS.md.) Archive block #72.

Scenario("Replacing a substring at several chosen positions")
	Given('"ring ruby ring php ring" (rings at 1, 11, 20)')
	o1 = new stzString("ring ruby ring php ring")
	o1.ReplaceXT("ring", :AtPositions = [ 1, 20 ], :By = "♥♥♥")
	Then("only the rings at 1 and 20 change; the one at 11 stays",
		o1.Content(), "♥♥♥ ruby ring php ♥♥♥")
EndScenario()

Summary()
