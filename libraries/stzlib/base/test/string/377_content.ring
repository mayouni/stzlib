load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :AfterNth = [n, anchor]) inserts after the n-th occurrence
# only. Archive block #377.

Scenario("Adding after the nth occurrence")
	Given('"__♥__(♥__♥__"')
	o1 = new stzString("__♥__(♥__♥__")
	o1.AddXT( ")", :AfterNth = [2, "♥"] )
	Then("only the second heart gets closed", o1.Content(), "__♥__(♥)__♥__")
EndScenario()

Summary()
