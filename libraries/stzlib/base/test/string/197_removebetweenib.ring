load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveBetweenIB(open, close) -- "Include Bounds": remove the content AND the
# bounds. Archive block #197.

Scenario("Removing the content and the bounds")
	Given('"__/♥\__"')
	o1 = new stzString("__/♥\__")
	o1.RemoveBetweenIB("/", "\")
	Then("the /♥\\ section is removed entirely", o1.Content(), "____")
EndScenario()

Summary()
