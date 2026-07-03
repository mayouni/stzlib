load "../../stzBase.ring"
load "../_narrated.ring"

# FindFirstXT(:BoundedBy): the first bounded occurrence, pair or
# single-string bound. Archive block #564.

Scenario("First heart between stars")
	o1 = new stzString("12*♥*56*♥*")
	Then("the pair spelling", o1.FindFirstXT("♥", :BoundedBy = [ "*", "*"]), 4)
	Then("the string spelling", o1.FindFirstXT("♥", :BoundedBy = "*"), 4)
EndScenario()

Summary()
