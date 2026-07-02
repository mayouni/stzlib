load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :BeforeEach = anchor) inserts before EVERY occurrence.
# Archive block #381.

Scenario("Adding before each occurrence")
	Given('"__♥)__♥)__♥)__"')
	o1 = new stzString("__♥)__♥)__♥)__")
	o1.AddXT( "(", :BeforeEach = "♥" )
	Then("every heart gets opened", o1.Content(), "__(♥)__(♥)__(♥)__")
EndScenario()

Summary()
