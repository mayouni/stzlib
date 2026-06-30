load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsAt(positions, sub) -- whether `sub` sits at all the listed positions.
# Archive block #178.
#

Scenario("Containment at a list of positions")
	Given('"♥^^♥^^♥" (hearts at 1, 4, 7)')
	Then("ContainsAt([1,4,7], '♥') is TRUE", Q("♥^^♥^^♥").ContainsAt([ 1, 4, 7 ], "♥"), TRUE)
	Then("ContainsXT('♥', :AtPositions=[1,4,7]) is TRUE", Q("♥^^♥^^♥").ContainsXT("♥", :AtPositions = [ 1, 4, 7 ]), TRUE)
EndScenario()

Summary()
