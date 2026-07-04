load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(:Last = sub, :From = context). Archive block #869.

Scenario("The stray trailing m")
	o1 = new stzString("Ring programmingm language")
	o1.RemoveXT( :Last = "m", :From = "programmingm")
	Then("fixed", o1.Content(), "Ring programming language")
EndScenario()

Summary()
