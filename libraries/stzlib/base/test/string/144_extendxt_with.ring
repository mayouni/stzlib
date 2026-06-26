load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendXT(:ToPosition = n, :With = c) -- pad with char c up to position n.
# Archive block #144.

Scenario("Extending to a position with a chosen char")
	o1 = new stzString("ABC")
	o1.ExtendXT( :ToPosition = 5, :With = "*" )
	Then("padded to position 5 with '*'", o1.Content(), "ABC**")
EndScenario()

Summary()
