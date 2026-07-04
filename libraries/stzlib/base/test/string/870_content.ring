load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(:Nth = [[n1, n2], sub], ...) removes several nths at once.
# Archive block #870.

Scenario("The first and third stars")
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Nth = [ [1, 3], "*" ], :From = "*progr*amming*")
	Then("only the middle one survives",
		o1.Content(), "Ring progr*amming language")
EndScenario()

Summary()
