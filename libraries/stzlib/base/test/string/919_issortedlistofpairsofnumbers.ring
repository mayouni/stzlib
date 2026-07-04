load "../../stzBase.ring"
load "../_narrated.ring"

# The sorted-pairs checkers. Archive block #919.

Scenario("Three sections in order")
	Then("sorted",
		IsSortedListOfPairsOfNumbers([ [4, 6], [10, 12], [16, 18] ]), TRUE)
	Then("sorted up",
		IsListOfPairsOfNumbersSortedUp([ [4, 6], [10, 12], [16, 18] ]), TRUE)
	Then("sorted down",
		IsListOfPairsOfNumbersSortedDown([ [16, 18], [10, 12], [4, 6] ]), TRUE)
EndScenario()

Summary()
