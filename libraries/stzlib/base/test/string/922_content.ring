load "../../stzBase.ring"
load "../_narrated.ring"

# The plain ReplaceCharsAtPositions tolerates any order.
# Archive block #922.

Scenario("Hearts at three positions")
	o1 = new stzString("AB3CD6EF9GH")
	o1.ReplaceCharsAtPositions([ 3, 9, 6 ], Heart())
	Then("all three replaced", o1.Content(), "AB♥CD♥EF♥GH")
EndScenario()

Summary()
