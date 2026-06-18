load "../../stzBase.ring"
load "../_narrated.ring"

# Narrated suite for stzDeepList -- the deep (nested) list / path API, kept in
# its own subclass (modular design). Values verified against the design doc
# stz-managing-deep-lists-narration.md. Run-for-real.

Scenario("DeepFind returns the path to every occurrence")
    Given("a nested list with 'h' at several depths")
    o = new stzDeepList([ "A", [ "h","B",[ "C","h","D","h" ],"h","E","h" ], "E" ])
    Then("DeepFind('h') -> the 5 documented paths",
        ListEq(o.DeepFind("h"), [ [2,1], [2,3,2], [2,3,4], [2,4], [2,6] ]), TRUE)
    Then("DeepContains('h') is TRUE", o.DeepContains("h"), TRUE)
    Then("DeepContains('Z') is FALSE", o.DeepContains("Z"), FALSE)
    Then("DeepFindAt('h',[2,3,2]) returns the path", ListEq(o.DeepFindAt("h",[2,3,2]), [2,3,2]), TRUE)
    Then("DeepFindAt('h',[2,2]) (not h there) returns []", ListEq(o.DeepFindAt("h",[2,2]), [ ]), TRUE)
EndScenario()

Scenario("Paths enumerates the whole structure (pre-order)")
    Given("the documented 4-branch nested list")
    o = new stzDeepList([ "item1", [ "item21", [ "item221","item222" ], "item23" ], [ "item31", [ "item321" ] ], "item4" ])
    Then("Paths() matches the documented enumeration",
        ListEq(o.Paths(), [ [1],[2],[2,1],[2,2],[2,2,1],[2,2,2],[2,3],[3],[3,1],[3,2],[3,2,1],[4] ]), TRUE)
    Then("ItemAtPath([2,2,2]) is item222", o.ItemAtPath([2,2,2]), "item222")
    Then("ItemsAtPaths([[2,2,2],[3,1],[4]]) -> the 3 items",
        ListEq(o.ItemsAtPaths([ [2,2,2],[3,1],[4] ]), [ "item222","item31","item4" ]), TRUE)
    Then("PathsAtDepth(2) -> the length-2 paths",
        ListEq(o.PathsAtDepth(2), [ [2,1],[2,2],[2,3],[3,1],[3,2] ]), TRUE)
EndScenario()

Scenario("Path analysis: longest, expand, collapse")
    Given("the 'h' nested list")
    o = new stzDeepList([ "A", [ "h","B",[ "C","h","D","h" ],"h","E","h" ], "E" ])
    Then("LongestPaths() -> the depth-3 paths under [2,3]",
        ListEq(o.LongestPaths(), [ [2,3,1],[2,3,2],[2,3,3],[2,3,4] ]), TRUE)
    Then("ExpandPath([2,3]) -> the branch plus its subpaths",
        ListEq(o.ExpandPath([2,3]), [ [2,3],[2,3,1],[2,3,2],[2,3,3],[2,3,4] ]), TRUE)
    Then("CollapsePath([2,3,4]) -> [2]", ListEq(o.CollapsePath([2,3,4]), [ 2 ]), TRUE)
EndScenario()

Scenario("Path-relationship globals and the DeepList() accessor")
    Then("IsSubPathOf([2],[2,3,4]) is TRUE", IsSubPathOf([2],[2,3,4]), TRUE)
    Then("IsSubPathOf([3],[2,3,4]) is FALSE", IsSubPathOf([3],[2,3,4]), FALSE)
    Then("CommonPath([[2,1,3],[2,1,4],[2,1,5]]) is [2,1]",
        ListEq(CommonPath([ [2,1,3],[2,1,4],[2,1,5] ]), [ 2, 1 ]), TRUE)
    Then("Q(list).DeepList() promotes to the deep API",
        ListEq(Q([ 1, [2,3] ]).DeepList().DeepFind(3), [ [2,2] ]), TRUE)
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
