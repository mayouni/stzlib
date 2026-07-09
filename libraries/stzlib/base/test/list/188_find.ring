# Narrative
# --------
# Finding a value inside a large numeric range with the global StzFindFirst().
#
# StzFindFirst(1:299_000, 40_000) searches the contiguous integer range from 1 to
# 299000 for the value 40000 and returns its 1-based position. Because the range
# starts at 1 and increments by 1, the position of any value equals the value
# itself, so the answer is 40000. This also shows StzFindFirst() handling a range
# expression (1:299_000) as the haystack without materializing concerns, and the
# numeric-underscore literal syntax (299_000, 40_000) for readability.
#
# Extracted from stzlisttest.ring, block #188.

load "../../stzBase.ring"
load "../_narrated.ring"

Scenario("Finding a value inside a large numeric range with the global StzFindFirst().")

	Then("find example 1", @@( StzFindFirst(1:299_000, 40_000) ), @@( 40000 ))
EndScenario()

Summary()
