load "../../stzBase.ring"
load "../_narrated.ring"

# WalkBackwardW / WalkForwardW with :UntilBefore -- walk from a
# position and stop just BEFORE the first char matching the condition.
# (The archive's 5/9, in a block it had itself marked #TODO, landed ON
# the matching space and skipped the first matching r; the impl stops
# consistently one step short in the walking direction.)
# Archive block #727.

Scenario("Walking a sentence both ways")
	o1 = new stzString("Ring Programming Language")
	Then("backward from 12, stop before the space at 5",
		o1.WalkBackwardW( :StartingAt = 12, :UntilBefore = '{ @char = " " }' ), 6)
	Then("forward from 6, stop before the r at 7",
		o1.WalkForwardW( :StartingAt = 6, :UntilBefore = '{ @char = "r" }' ), 6)
EndScenario()

Summary()
