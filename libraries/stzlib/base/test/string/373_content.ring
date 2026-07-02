load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveFromStart / RemoveFromEnd peel a given substring off the edges.
# Archive block #373.

Scenario("Removing from the edges")
	Given('"{HELLO}"')
	o1 = new stzString("{HELLO}")
	o1.RemoveFromStart("{")
	Then("the opening brace goes", o1.Content(), "HELLO}")
	o1.RemoveFromEnd("}")
	Then("the closing brace goes", o1.Content(), "HELLO")
EndScenario()

Summary()
