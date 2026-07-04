load "../../stzBase.ring"
load "../_narrated.ring"

# :AfterEach -- every occurrence gets cleaned. Archive block #873.

Scenario("Three closers after three hearts")
	o1 = new stzString("__♥)__♥)__♥)__")
	o1.RemoveXT( ")", :AfterEach = "♥" )
	Then("all three gone", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
