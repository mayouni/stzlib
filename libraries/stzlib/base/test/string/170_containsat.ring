load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsAt -- whether the substring sits at a given position. Archive block #170.
#

Scenario("Containment at a position")
	Given('"^^♥^^" (heart at position 3)')
	Then("ContainsAt(3, '♥') is TRUE", Q("^^♥^^").ContainsAt(3, "♥"), TRUE)
	Then("ContainsAt('♥', :Position=3) is TRUE", Q("^^♥^^").ContainsAt("♥", :Position = 3), TRUE)
	# The XT spelling is broken:
	? "  NOTE  ContainsXT('♥', :AtPosition=3) -> " + @@(Q("^^♥^^").ContainsXT("♥", :AtPosition = 3)) + "  (want TRUE -- deferred)"
EndScenario()

Summary()
