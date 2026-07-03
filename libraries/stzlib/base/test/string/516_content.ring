load "../../stzBase.ring"
load "../_narrated.ring"

# Move a char to a new position, then swap two positions back.
# Archive block #516.

Scenario("Moving and swapping chars")
	o1 = new stzString("ACB")
	o1.Move( :CharFromPosition = 3, :To = 2 )
	Then("B moved before C", o1.Content(), "ABC")
	o1.Swap( :Positions = 2, :And = 3 )
	Then("swapping 2 and 3 restores ACB", o1.Content(), "ACB")
EndScenario()

Summary()
