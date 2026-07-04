load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(:Each = sub, :From = context). Archive block #866.

Scenario("Three stars, all gone")
	o1 = new stzString("Ring *progr*amming* language")
	o1.RemoveXT( :Each = "*", :From = "*progr*amming*")
	Then("clean", o1.Content(), "Ring programming language")
EndScenario()

Summary()
