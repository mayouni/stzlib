load "../../stzBase.ring"
load "../_narrated.ring"

# :BeforeEach. Archive block #878.

Scenario("Three openers before three hearts")
	o1 = new stzString("__(♥__(♥__(♥__")
	o1.RemoveXT( "(", :BeforeEach = "♥" )
	Then("all three gone", o1.Content(), "__♥__♥__♥__")
EndScenario()

Summary()
