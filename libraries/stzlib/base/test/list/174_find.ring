# Narrative
# --------
# Finds a value inside a numeric range using the global StzFindFirst().
#
# The range 1:100_000 is the list of integers from 1 to 100000, so the
# value 67_000 sits at position 67000 (in a 1-based, contiguous range the
# position equals the value). StzFindFirst() returns that 1-based position,
# demonstrating that the engine-backed find works directly on Softanza
# ranges without first materializing a wrapper list, and that Ring's
# underscore digit grouping (67_000) is just sugar for 67000.
#
# Extracted from stzlisttest.ring, block #174.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Finds a value inside a numeric range using the global StzFindFirst().")

	Then("find example 1", @@( StzFindFirst( 1:100_000, 67_000 ) ), @@( 67000 ))
EndScenario()

Summary()
