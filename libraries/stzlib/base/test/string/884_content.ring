load "../../stzBase.ring"
load "../_narrated.ring"

# :AroundNth = [n, anchor]. Archive block #884.

Scenario("Only around the second heart")
	o1 = new stzString("__♥__/♥\__♥__")
	o1.RemoveXT([ "/", "\" ], :AroundNth = [2, "♥"])
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
