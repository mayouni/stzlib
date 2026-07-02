load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :AfterEach = anchor) inserts after EVERY occurrence.
# Archive block #376.

Scenario("Adding after each occurrence")
	Given('"__(♥__(♥__(♥__"')
	o1 = new stzString("__(♥__(♥__(♥__")
	o1.AddXT( ")", :AfterEach = "♥" )
	Then("every heart gets closed", o1.Content(), "__(♥)__(♥)__(♥)__")
EndScenario()

Summary()
