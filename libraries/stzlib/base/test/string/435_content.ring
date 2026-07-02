load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisFirstChar / RemoveThisLastChar remove the edge char only when
# it equals the given one. Archive block #435.

Scenario("Peeling matching braces")
	Given('"{abc}"')
	o1 = new stzString("{abc}")
	o1.RemoveThisFirstChar("{")
	o1.RemoveThisLastChar("}")
	Then("both braces gone", o1.Content(), "abc")
EndScenario()

Summary()
