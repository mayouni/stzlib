load "../../stzBase.ring"
load "../_narrated.ring"

# :AfterFirst. Archive block #875.

Scenario("Only after the first heart")
	o1 = new stzString("__♥)__♥__♥__")
	o1.RemoveXT( ")", :AfterFirst = "♥" )
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
