# Narrative
# --------
# Find(value) returns every position at which a value appears in a list.
#
# Softanza's Find is value-based and exhaustive: rather than stopping at
# the first match like Ring's builtin find(), it scans the whole list and
# returns a list of 1-based positions for all occurrences. Here the value 3
# sits at positions 3 and 6 of [1, 2, 3, 4, 5, 3, 7], so Find(3) yields
# [ 3, 6 ]. This "all positions" contract is the foundation for the wider
# FindAll / replace-by-value family that operates on every hit at once.
#
# Extracted from stzlisttest.ring, block #189.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Find(value) returns every position at which a value appears in a list.")

	Then("find example 1", @@( Q([1, 2, 3, 4, 5, 3, 7]).Find(3) ), @@( [ 3, 6 ] ))
EndScenario()

Summary()
