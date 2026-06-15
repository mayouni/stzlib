load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzList -- a representative core of the
# engine-backed list surface: count, membership/find, reverse, sort, dedup,
# add, occurrences, slicing, reducers. Not exhaustive (the domain has ~670
# classic blocks); this is the run-for-real safety net for the central
# operations. Deterministic. Objects via Q(...).

Scenario("Count, membership and find")
    Given("the list [3,1,2,1]")
    o = Q([ 3, 1, 2, 1 ])
    Then("NumberOfItems is 4", o.NumberOfItems(), 4)
    Then("Contains(2) is TRUE", o.Contains(2), TRUE)
    Then("Contains(9) is FALSE", o.Contains(9), FALSE)
    Then("Find(2) -> [3]", ListEq(o.Find(2), [ 3 ]), TRUE)
    Then("Find(1) -> [2,4]", ListEq(o.Find(1), [ 2, 4 ]), TRUE)
    Then("NumberOfOccurrences(1) is 2", o.NumberOfOccurrences(1), 2)
EndScenario()

Scenario("Reverse, sort, dedup")
    Then("Reversed([1,2,3]) is [3,2,1]", ListEq(Q([1,2,3]).Reversed(), [ 3, 2, 1 ]), TRUE)
    Then("Sorted([3,1,2]) is [1,2,3]", ListEq(Q([3,1,2]).Sorted(), [ 1, 2, 3 ]), TRUE)
    Then("RemoveDuplicates keeps first occurrences", ListEq(Q([1,2,1,3,2]).RemoveDuplicatesQ().Content(), [ 1, 2, 3 ]), TRUE)
EndScenario()

Scenario("Add and slice")
    Then("AddQ(3) appends", ListEq(Q([1,2]).AddQ(3).Content(), [ 1, 2, 3 ]), TRUE)
    Then("FirstItem is 10", Q([10,20,30]).FirstItem(), 10)
    Then("LastItem is 30", Q([10,20,30]).LastItem(), 30)
    Then("Section(2,4) is [2,3,4]", ListEq(Q([1,2,3,4,5]).Section(2,4), [ 2, 3, 4 ]), TRUE)
EndScenario()

Scenario("Reducers and emptiness")
    Then("Sum([1,2,3,4]) is 10", Q([1,2,3,4]).Sum(), 10)
    Then("IsEmpty([]) is TRUE", Q([]).IsEmpty(), TRUE)
    Then("IsEmpty([1]) is FALSE", Q([1]).IsEmpty(), FALSE)
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
