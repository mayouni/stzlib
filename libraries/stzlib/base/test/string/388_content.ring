load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT([open, close], :AroundFirst = anchor) wraps the FIRST occurrence.
# Archive block #388.

Scenario("Wrapping the first occurrence")
	Given('"__♥__/♥\__/♥\__"')
	o1 = new stzString("__♥__/♥\__/♥\__")
	o1.AddXT( [ "/","\" ], :AroundFirst = "♥" )
	Then("the bare first heart joins the flock", o1.Content(), "__/♥\__/♥\__/♥\__")
EndScenario()

Summary()
