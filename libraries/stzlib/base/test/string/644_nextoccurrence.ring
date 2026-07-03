load "../../stzBase.ring"
load "../_narrated.ring"

# NextOccurrence / NextNthOccurrence with named params.
# Archive block #644.

Scenario("Semicolons in a record")
	o1 = new stzString("12500;NAME;10;0")
	Then("the next one from 1",
		o1.NextOccurrence( :Of = ";", :StartingAt = 1 ), 6)
	Then("the 2nd from 5",
		o1.NextNthOccurrence( 2, :Of = ";", :StartingAt = 5), 11)
EndScenario()

Summary()
