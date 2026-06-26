load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendXT(:String, :ToPosition = n) -- pad with spaces up to position n.
# Archive block #141.

Scenario("Extending a string to a position with spaces")
	o1 = new stzString("ABC")
	o1.ExtendXT( :String, :ToPosition = 5 )
	Then("padded to position 5", o1.Content(), "ABC  ")
EndScenario()

Summary()
