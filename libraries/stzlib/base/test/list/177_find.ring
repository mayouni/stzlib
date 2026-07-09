# Narrative
# --------
# The Find family: locating where a value lives inside a list.
#
# Find(value) returns every position the value occupies, as a list
# of 1-based indices -- here 14 sits at positions 1, 3 and 4. The
# convenience accessors FindFirst and FindLast pull just the leading
# and trailing match (1 and 4). FindNext(value, :StartingAt = n)
# resumes the scan from position n, so starting at 2 skips the first
# hit and returns the next match at 3. Together they form Softanza's
# positional vocabulary for value lookup on a plain stzList.
#
# Extracted from stzlisttest.ring, block #177.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("The Find family: locating where a value lives inside a list.")

	o1 = new stzList([ 14, 10, 14, 14, 20 ])

	Then("find example 1", @@( o1.Find(14) ), @@( [ 1, 3, 4 ] ))

	Then("find example 2", @@( o1.FindFirst(14) ), @@( 1 ))

	Then("find example 3", @@( o1.FindLast(14) ), @@( 4 ))

	Then("find example 4", @@( o1.FindNext(14, :StartingAt = 2) ), @@( 3 ))
EndScenario()

Summary()
