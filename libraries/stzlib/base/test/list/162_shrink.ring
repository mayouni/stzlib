# Narrative
# --------
# Shrink() truncates a list down to a target position, discarding the tail.
# Calling Shrink(:ToPosition = 3) on [ "A", "B", "C", "D", "E" ] keeps only
# the first three items, mutating the object in place. The :ToPosition named
# argument reads as a self-documenting "shrink the list so it ends at this
# position" idiom -- the Softanza preference over a bare numeric length.
#
# Extracted from stzlisttest.ring, block #162 (Scenario form).

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Shrink truncates a list to a position, discarding the tail")
	o1 = new stzList([ "A", "B", "C", "D", "E" ])
	o1.Shrink( :ToPosition = 3 )
	Then("Shrink(:ToPosition = 3) keeps only the first three items",
		@@( o1.Content() ), @@([ "A", "B", "C" ]))
EndScenario()

Summary()
