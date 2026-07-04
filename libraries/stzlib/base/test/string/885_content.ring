load "../../stzBase.ring"
load "../_narrated.ring"

# :AroundFirst. Archive block #885.

Scenario("Only around the first heart")
	o1 = new stzString("__/♥\__♥__♥__")
	o1.RemoveXT( [ "/", "\" ], :AroundFirst = "♥" )
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
