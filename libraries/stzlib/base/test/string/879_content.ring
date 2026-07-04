load "../../stzBase.ring"
load "../_narrated.ring"

# :BeforeNth = [n, anchor]. Archive block #879.

Scenario("Only before the second heart")
	o1 = new stzString("__♥__(♥__♥__")
	o1.RemoveXT( "(", :BeforeNth = [2, "♥"] )
	Then("cleaned", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
