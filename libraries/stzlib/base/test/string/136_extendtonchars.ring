load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendToNChars(n) -- pad with spaces up to length n. Archive block #136.

Scenario("Extending to a fixed width with spaces")
	o1 = new stzString("ABC")
	o1.ExtendToNChars(5)
	Then("'ABC' padded to width 5", o1.Content(), "ABC  ")
EndScenario()

Summary()
