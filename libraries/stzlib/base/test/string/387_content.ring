load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT([open, close], :AroundNth = [n, anchor]) wraps the n-th occurrence
# only. Archive block #387.

Scenario("Wrapping the nth occurrence")
	Given('"__♥__♥__♥__"')
	o1 = new stzString("__♥__♥__♥__")
	o1.AddXT([ "/","\" ], :AroundNth = [2, "♥"])
	Then("only the second heart gets wings", o1.Content(), "__♥__/♥\__♥__")
EndScenario()

Summary()
