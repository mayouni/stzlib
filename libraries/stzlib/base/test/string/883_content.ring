load "../../stzBase.ring"
load "../_narrated.ring"

# ... and a [pre, post] pair puts a different substring on each side.
# Archive block #883.

Scenario("Slashes around three hearts")
	o1 = new stzString("__/♥\__/♥\__/♥\__")
	o1.RemoveXT([ "/", "\" ], :Around = "♥")
	Then("all pairs gone", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
