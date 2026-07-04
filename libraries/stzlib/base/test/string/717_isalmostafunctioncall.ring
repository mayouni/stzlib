load "../../stzBase.ring"
load "../_narrated.ring"

# IsAlmostAFunctionCall -- used internally when evaluating conditional
# code. Archive block #717.

Scenario("Things that look like calls")
	Then("a bare call",
		StzStringQ('myfunc()').IsAlmostAFunctionCall(), TRUE)
	Then("a call with args",
		StzStringQ('my_func("name")').IsAlmostAFunctionCall(), TRUE)
EndScenario()

Summary()
