load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :BeforeFirst = anchor) inserts before the FIRST occurrence.
# Archive block #383.

Scenario("Adding before the first occurrence")
	Given('"__♥)__♥__♥__"')
	o1 = new stzString("__♥)__♥__♥__")
	o1.AddXT( "(", :BeforeFirst = "♥" )
	Then("the first heart gets opened", o1.Content(), "__(♥)__♥__♥__")
EndScenario()

Summary()
