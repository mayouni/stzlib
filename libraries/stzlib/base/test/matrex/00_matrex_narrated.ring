load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzMatrex -- matrix-shape pattern
# matching, e.g. "{Size(3x3)}".Match(aMatrix). Deterministic.
#
# Regression guard: Match() previously returned FALSE for EVERY input
# because the pattern parser used @StzMid with end-based args while the
# global @StzMid is count-based, so patterns never tokenised. Fixed via an
# end-based _Mid() helper. Each pattern is tested with a matching AND a
# non-matching matrix.

Scenario("Exact size")
    Given("a 3x3 and a 2x3 matrix")
    a3x3 = [ [1,2,3], [4,5,6], [7,8,9] ]
    a2x3 = [ [1,2,3], [4,5,6] ]
    Then("{Size(3x3)} matches the 3x3", Mtx("{Size(3x3)}").Match(a3x3), TRUE)
    Then("{Size(3x3)} rejects the 2x3", Mtx("{Size(3x3)}").Match(a2x3), FALSE)
    Then("{Size(2x2)} rejects the 3x3", Mtx("{Size(2x2)}").Match(a3x3), FALSE)
EndScenario()

Scenario("Any size (mxn)")
    Then("{size(mxn)} matches a 3x3", Mtx("{size(mxn)}").Match([ [1,2,3],[4,5,6],[7,8,9] ]), TRUE)
    Then("{size(mxn)} matches a 2x3", Mtx("{size(mxn)}").Match([ [1,2,3],[4,5,6] ]), TRUE)
EndScenario()

Scenario("Shape constraints")
    Given("a square and a rectangular matrix")
    aSquare = [ [1,2], [3,4] ]
    aRect   = [ [1,2,3], [4,5,6] ]
    Then("{shape(square)} matches the 2x2 square", Mtx("{shape(square)}").Match(aSquare), TRUE)
    Then("{shape(square)} matches a 3x3 square", Mtx("{shape(square)}").Match([ [1,2,3],[4,5,6],[7,8,9] ]), TRUE)
    Then("{shape(square)} rejects the rectangle", Mtx("{shape(square)}").Match(aRect), FALSE)
EndScenario()

Summary()

func Mtx cPattern
    return new stzMatrex(cPattern)
