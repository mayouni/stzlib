load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(sub, :At = n, :With = new) replaces sub at the CHAR position n (not
# the nth occurrence). Archive block #192.

Scenario("Replacing at a char position")
	Given('"~♥/♥\~~"')
	o1 = new stzString("~♥/♥\~~")
	o1.ReplaceXT("♥", :At = 2, :With = "~")
	Then("the heart at position 2 becomes '~'", o1.Content(), "~~/♥\~~")
EndScenario()

Summary()
