load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :AfterLast = anchor) inserts after the LAST occurrence
# (:ToLast works too). Archive block #379.

Scenario("Adding after the last occurrence")
	Given('"__♥__♥__(♥__"')
	o1 = new stzString("__♥__♥__(♥__")
	o1.AddXT( ")", :AfterLast = "♥" )
	Then("the last heart gets closed", o1.Content(), "__♥__♥__(♥)__")
EndScenario()

Summary()
