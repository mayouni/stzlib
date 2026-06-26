load "../../stzBase.ring"
load "../_narrated.ring"

# FindNth(list, n, item, :StartingAt = p) -- the position of the n-th occurrence
# of `item` counting from position p. FindNextNth counts the n-th AFTER p.
# Archive block #164.

Scenario("Finding the n-th occurrence from a start offset")
	Given('[ 1, "♥", 3, 4, "♥", 5, "♥" ] (hearts at 2, 5, 7)')
	aList = [ 1, "♥", 3, 4, "♥", 5, "♥" ]
	Then("2nd heart from position 2 is at 5", FindNth(aList, 2, "♥", :StartingAt = 2), 5)
	Then("2nd heart from position 3 is at 7", FindNth(aList, 2, "♥", :StartingAt = 3), 7)
	Then("FindNextNth(2, from 2) skips position 2's heart -> 7", FindNextNth(aList, 2, "♥", :StartingAt = 2), 7)
EndScenario()

Summary()
