load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :AfterFirst = anchor) inserts after the FIRST occurrence
# (:ToFirst works too). NOTE: the archive #--> pasted block #377's result;
# with the "(" sitting before the FIRST heart here, the close lands there.
# Archive block #378.

Scenario("Adding after the first occurrence")
	Given('"__(♥__♥__♥__"')
	o1 = new stzString("__(♥__♥__♥__")
	o1.AddXT( ")", :AfterFirst = "♥" )
	Then("the first heart gets closed", o1.Content(), "__(♥)__♥__♥__")
EndScenario()

Summary()
