load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT([open, close], :AroundEach = anchor) wraps every occurrence with a
# distinct open/close pair. Archive block #386.

Scenario("Wrapping each occurrence with slashes")
	Given('"__♥__♥__♥__"')
	o1 = new stzString("__♥__♥__♥__")
	o1.AddXT([ "/","\" ], :AroundEach = "♥")
	Then("every heart gets its wings", o1.Content(), "__/♥\__/♥\__/♥\__")
EndScenario()

Summary()
