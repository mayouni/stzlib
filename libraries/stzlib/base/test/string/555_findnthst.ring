load "../../stzBase.ring"
load "../_narrated.ring"

# FindNthST / FindFirstST: nth and first occurrence from a position.
# Archive block #555.

Scenario("Stars from position 4")
	o1 = new stzString("12*45*78*90")
	Then("the 2nd star from 4", o1.FindNthST(2, "*", :StartingAt = 4), 9)
	Then("the first star from 4", o1.FindFirstST("*", :StartingAt = 4), 6)
EndScenario()

Summary()
