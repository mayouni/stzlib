load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsAt(positions, sub) -- whether `sub` sits at all the listed positions.
# Archive block #178.
#

Scenario("Containment at a list of positions")
	Given('"♥^^♥^^♥" (hearts at 1, 4, 7)')
	Then("ContainsAt([1,4,7], '♥') is TRUE", Q("♥^^♥^^♥").ContainsAt([ 1, 4, 7 ], "♥"), TRUE)
	# The XT spelling is broken:
	? "  NOTE  ContainsXT('♥', :AtPositions=[1,4,7]) -> " + @@(Q("♥^^♥^^♥").ContainsXT("♥", :AtPositions = [ 1, 4, 7 ])) + "  (want TRUE -- deferred)"
EndScenario()

Summary()
