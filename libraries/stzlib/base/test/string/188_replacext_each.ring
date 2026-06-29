load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(:Each = sub, [], :With = new) replaces EVERY occurrence; the inverse
# form ReplaceXT(sub, :With = new, []) does the same with the sub first. Both
# route to ReplaceAll. Archive block #188.

Scenario("Replacing every occurrence two ways")
	Given('"♥♥♥ Ring programing language ♥♥♥"')
	o1 = new stzString("♥♥♥ Ring programing language ♥♥♥")
	o1.ReplaceXT( :Each = "♥", [], :With = "*")
	Then("every heart becomes a star", o1.Content(), "*** Ring programing language ***")
	o1.ReplaceXT("*", :With = "♥", [])
	Then("and back again", o1.Content(), "♥♥♥ Ring programing language ♥♥♥")
EndScenario()

Summary()
