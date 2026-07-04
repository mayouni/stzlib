load "../../stzBase.ring"
load "../_narrated.ring"

# :AfterNth = [n, anchor]. Archive block #874.

Scenario("Only after the second heart")
	o1 = new stzString("__♥__♥)__♥__")
	o1.RemoveXT( ")", :AfterNth = [2, "♥"] )
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
