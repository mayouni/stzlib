load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzListOfLists -- a jagged list of
# lists (rows of differing length). Deterministic: sizes, missing-cell
# analysis, row/column access.

Scenario("Size and missing-cell analysis of a jagged list")
    Given("3 rows of length 4, 3 and 2")
    o = Lll([ [ "mohannad", 100, "hi", "ring" ], [ "karim", 20, "hi" ], [ "salem", 67 ] ])
    Then("NumberOfLists is 3", o.NumberOfLists(), 3)
    Then("Sizes are [4,3,2]", ListEq(o.Sizes(), [ 4, 3, 2 ]), TRUE)
    Then("MinSize is 2", o.MinSize(), 2)
    Then("MaxSize is 4", o.MaxSize(), 4)
    Then("HowManyMissing is 3 (cells short of rectangular)", o.HowManyMissing(), 3)
    Then("FindMissing pinpoints the empty cells", ListEq(o.FindMissing(), [ [ 2, 4 ], [ 3, 3 ], [ 3, 4 ] ]), TRUE)
EndScenario()

Scenario("Row and column access")
    Given("a 3-row jagged list")
    o = Lll([ [ "mohannad", 100, "him", "ring" ], [ "karim", 20, "hi" ], [ "salem", 67 ] ])
    Then("NthList(3) returns the third row", ListEq(o.NthList(3), [ "salem", 67 ]), TRUE)
    Then("NthCol(3) gathers column 3 where present", ListEq(o.NthCol(3), [ "him", "hi" ]), TRUE)
    Then("NthCol(4) returns the lone column-4 value", ListEq(o.NthCol(4), [ "ring" ]), TRUE)
EndScenario()

Scenario("The @IsListOfLists predicate")
    Then("a list of lists is recognised", @IsListOfLists([ [ 1, 2 ], [ 3 ] ]), TRUE)
    Then("a flat list is not a list of lists", @IsListOfLists([ 1, 2, 3 ]), FALSE)
EndScenario()

Summary()

func Lll aList
    return new stzListOfLists(aList)

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
