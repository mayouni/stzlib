load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :BeforeLast = anchor) inserts before the LAST occurrence.
# Archive block #384.

Scenario("Adding before the last occurrence")
	Given('"__♥__♥__♥)__"')
	o1 = new stzString("__♥__♥__♥)__")
	o1.AddXT( "(", :BeforeLast = "♥" )
	Then("the last heart gets opened", o1.Content(), "__♥__♥__(♥)__")
EndScenario()

Summary()
