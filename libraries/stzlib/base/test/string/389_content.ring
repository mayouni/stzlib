load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT([open, close], :AroundLast = anchor) wraps the LAST occurrence.
# Archive block #389.

Scenario("Wrapping the last occurrence")
	Given('"__/♥\__/♥\__♥__"')
	o1 = new stzString("__/♥\__/♥\__♥__")
	o1.AddXT( [ "/","\" ], :AroundLast = "♥" )
	Then("the bare last heart joins the flock", o1.Content(), "__/♥\__/♥\__/♥\__")
EndScenario()

Summary()
