load "../../stzBase.ring"
load "../_narrated.ring"

# :AroundLast. Archive block #886.

Scenario("Only around the last heart")
	o1 = new stzString("__♥__♥__/♥\__")
	o1.RemoveXT( [ "/", "\" ], :AroundLast = "♥" )
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
