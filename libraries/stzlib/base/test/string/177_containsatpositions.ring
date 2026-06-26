load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsAtPositions(positions, sub) / ContainsAtPosition(sub, p) -- whether the
# substring sits at all the given positions / at a single position. Archive #177.

Scenario("Containment at several positions")
	Then("hearts sit at 2, 5, 8", Q("^♥^^♥^^♥^").ContainsAtPositions([ 2, 5, 8 ], "♥"), TRUE)
	Then("a heart sits at position 1", Q("♥^^♥^^♥").ContainsAtPosition("♥", 1), TRUE)
EndScenario()

Summary()
