load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveBetween(open, close) -- remove the content between the bounds, keeping the
# bounds themselves. Archive block #196.

Scenario("Removing the content between two bounds")
	Given('"__/♥\__"')
	o1 = new stzString("__/♥\__")
	o1.RemoveBetween("/", "\")
	Then("the heart between / and \\ is gone, bounds kept", o1.Content(), "__/\__")
EndScenario()

Summary()
