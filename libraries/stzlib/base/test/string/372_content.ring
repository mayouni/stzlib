load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveSection(n1, n2) cuts the span out, in place. Archive block #372.

Scenario("Removing a section")
	Given('"ABC456DE"')
	o1 = new stzString("ABC456DE")
	o1.RemoveSection(4, 6)
	Then("the digits vanish", o1.Content(), "ABCDE")
EndScenario()

Summary()
