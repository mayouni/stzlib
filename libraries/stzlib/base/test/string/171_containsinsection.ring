load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsInSection(sub, n1, n2) and its ContainsBetweenPositions alias check
# whether sub appears within the section. Archive block #171.

Scenario("Checking a char within sections")
	Given('"^^♥^^" (heart at position 3)')
	Then("'♥' is in section 2..4", Q("^^♥^^").ContainsInSection("♥", 2, 4), TRUE)
	Then("ContainsBetweenPositions agrees", Q("^^♥^^").ContainsBetweenPositions("♥", 2, 4), TRUE)
	Then("'♥' is in section 1..3", Q("^^♥^^").ContainsInSection("♥", 1, 3), TRUE)
EndScenario()

Summary()
