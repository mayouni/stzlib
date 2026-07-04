load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(sub, :Before = anchor). Archive block #877.

Scenario("Stars before programming")
	o1 = new stzString("Ring ***programming language.")
	o1.RemoveXT("***", :Before = "programming")
	Then("stars gone", o1.Content(), "Ring programming language.")
EndScenario()

Summary()
