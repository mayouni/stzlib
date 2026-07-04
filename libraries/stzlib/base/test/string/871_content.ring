load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveFromEnd. Archive block #871.

Scenario("A star off the tail")
	o1 = new stzString("programming*")
	o1.RemoveFromEnd("*")
	Then("bare word", o1.Content(), "programming")
EndScenario()

Summary()
