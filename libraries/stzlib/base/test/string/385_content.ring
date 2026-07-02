load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(sep, :AroundEach = anchor) wraps EVERY occurrence with the same
# separator on both sides. Archive block #385.

Scenario("Wrapping each occurrence with spaces")
	Given('"__♥__♥__♥__"')
	o1 = new stzString("__♥__♥__♥__")
	o1.AddXT(" ", :AroundEach = "♥")
	Then("every heart breathes", o1.Content(), "__ ♥ __ ♥ __ ♥ __")
EndScenario()

Summary()
