load "../../stzBase.ring"
load "../_narrated.ring"

# MultiplyBy a LIST distributes the string over its items.
# Archive block #757.

Scenario("a times three suffixes")
	o1 = new stzString("a")
	o1.MultiplyBy([ "b", "c", "d" ])
	Then("ab + ac + ad", o1.Content(), "abacad")
EndScenario()

Summary()
