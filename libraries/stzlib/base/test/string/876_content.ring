load "../../stzBase.ring"
load "../_narrated.ring"

# :AfterLast. Archive block #876.

Scenario("Only after the last heart")
	o1 = new stzString("__♥__♥__♥)__")
	o1.RemoveXT( ")", :AfterLast = "♥" )
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
