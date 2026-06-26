load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(sub, :AtPositions = [p1, p2], :With = new) -- replace at each listed
# position. Archive block #193. (The plural :AtPositions form works; the singular
# :AtPosition is broken -- block 71.)

Scenario("Replacing at several positions")
	Given('"~♥/♥\~♥" (hearts at 2 and 7)')
	o1 = new stzString("~♥/♥\~♥")
	o1.ReplaceXT("♥", :AtPositions = [2, 7], :With = "~")
	Then("hearts at 2 and 7 become ~", o1.Content(), "~~/♥\~~")
EndScenario()

Summary()
