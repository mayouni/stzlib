load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(:First = sub, :From = context). Archive block #868.

Scenario("The stray leading m")
	o1 = new stzString("Ring mprogramming language")
	o1.RemoveXT( :First = "m", :From = "mprogramming")
	Then("fixed", o1.Content(), "Ring programming language")
EndScenario()

Summary()
