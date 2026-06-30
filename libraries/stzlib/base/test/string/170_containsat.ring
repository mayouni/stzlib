load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsAt -- whether the substring sits at a given position. Archive block #170.
#

Scenario("Containment at a position")
	Given('"^^♥^^" (heart at position 3)')
	Then("ContainsAt(3, '♥') is TRUE", Q("^^♥^^").ContainsAt(3, "♥"), TRUE)
	Then("ContainsAt('♥', :Position=3) is TRUE", Q("^^♥^^").ContainsAt("♥", :Position = 3), TRUE)
	Then("ContainsXT('♥', :AtPosition=3) is TRUE", Q("^^♥^^").ContainsXT("♥", :AtPosition = 3), TRUE)
EndScenario()

Summary()
