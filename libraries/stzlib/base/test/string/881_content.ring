load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT :BeforeLast. Archive block #881.

Scenario("Only before the last heart")
	o1 = new stzString("__♥__♥__(♥__")
	o1.RemoveXT( "(", :BeforeLast = "♥" )
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
