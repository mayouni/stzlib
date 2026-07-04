load "../../stzBase.ring"
load "../_narrated.ring"

# :BeforeFirst. Archive block #880.

Scenario("Only before the first heart")
	o1 = new stzString("__(♥__♥__♥__")
	o1.RemoveXT( "(", :BeforeFirst = "♥" )
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
