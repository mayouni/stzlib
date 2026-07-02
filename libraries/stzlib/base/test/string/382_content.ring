load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :BeforeNth = [n, anchor]) inserts before the n-th occurrence
# only. Archive block #382.

Scenario("Adding before the nth occurrence")
	Given('"__♥__♥)__♥__"')
	o1 = new stzString("__♥__♥)__♥__")
	o1.AddXT( "(", :BeforeNth = [2, "♥"] )
	Then("only the second heart gets opened", o1.Content(), "__♥__(♥)__♥__")
EndScenario()

Summary()
