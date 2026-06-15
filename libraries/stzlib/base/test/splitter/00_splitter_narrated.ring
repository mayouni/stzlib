load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzSplitter -- splits the integer range
# 1..N at positions / sections, returning the surviving [from,to] segments.
# Deterministic.

Scenario("Split at a single position")
    Given("a splitter over 1..10")
    o = new stzSplitter(10)
    Then("SplitAt(5) drops 5 -> [1,4],[6,10]", ListEq(o.SplitAt(:Position = 5), [ [ 1, 4 ], [ 6, 10 ] ]), TRUE)
    Then("SplitAt(1) drops the head -> [2,10]", ListEq(o.SplitAt(:Position = 1), [ [ 2, 10 ] ]), TRUE)
    Then("SplitAt(10) drops the tail -> [1,9]", ListEq(o.SplitAt(:Position = 10), [ [ 1, 9 ] ]), TRUE)
EndScenario()

Scenario("Split at several positions")
    Given("the same splitter")
    o = new stzSplitter(10)
    Then("SplitAt([3,7]) -> [1,2],[4,6],[8,10]", ListEq(o.SplitAt([ 3, 7 ]), [ [ 1, 2 ], [ 4, 6 ], [ 8, 10 ] ]), TRUE)
EndScenario()

Scenario("Split removing whole sections")
    Given("splitters over 1..10 and 1..5")
    o = new stzSplitter(10)
    Then("SplitAtSection(4,7) -> [1,3],[8,10]", ListEq(o.SplitAtSection(4, 7), [ [ 1, 3 ], [ 8, 10 ] ]), TRUE)
    Then("SplitAtSections([[3,5],[7,8]]) -> [1,2],[6,6],[9,10]", ListEq(o.SplitAtSections([ [ 3, 5 ], [ 7, 8 ] ]), [ [ 1, 2 ], [ 6, 6 ], [ 9, 10 ] ]), TRUE)
    b = new stzSplitter(5)
    Then("SplitAtSection(2,4) over 1..5 -> [1,1],[5,5]", ListEq(b.SplitAtSection(2, 4), [ [ 1, 1 ], [ 5, 5 ] ]), TRUE)
EndScenario()

Summary()

func ListEq aA, aE
    if len(aA) != len(aE) return FALSE ok
    nLen = len(aA)
    for i = 1 to nLen
        if isList(aA[i]) and isList(aE[i])
            if NOT ListEq(aA[i], aE[i]) return FALSE ok
        else
            if aA[i] != aE[i] return FALSE ok
        ok
    next
    return TRUE
