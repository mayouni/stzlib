load "../../stzBase.ring"
load "../_narrated.ring"

# DistanceTo("6", :StartingAt = 4) counts the chars strictly BETWEEN
# position 4 and the next "6" (exclusive: just position 5 -> 1); the XT
# form counts the two bounding positions too (4,5,6 -> 3).
# Extracted from stzlisttest.ring, block #308.

Scenario("Distance from a position to a char")
	Given('"---456---"')
	o1 = new stzString("---456---")
	Then("the exclusive gap", o1.DistanceTo("6", :StartingAt = 4), 1)
	Then("the inclusive XT distance", o1.DistanceToXT("6", :StartingAt = 4), 3)
EndScenario()

Summary()
