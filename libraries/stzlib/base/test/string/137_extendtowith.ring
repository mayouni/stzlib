load "../../stzBase.ring"
load "../_narrated.ring"

# ExtendToWith(n, c) -- pad with the char c up to length n. Archive block #137.

Scenario("Extending to a fixed width with a chosen char")
	o1 = new stzString("ABC")
	o1.ExtendToWith(5, "*")
	Then("'ABC' padded to width 5 with '*'", o1.Content(), "ABC**")
EndScenario()

Summary()
