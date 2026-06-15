load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzSortedList (engine-backed sort +
# sorted insert). Deterministic.
#
# Regression guards (both fixed this session):
#  - Add() was a silent no-op: it passed a value HANDLE minted by the value
#    DLL to StzEngineListSortedInsert in the list DLL, where it didn't resolve
#    (per-DLL handle tables) -> garbage -> panic/no-op. Add() now uses the
#    type-specific StzEngineListSortedInsert{Int,Float,String} which build the
#    value inside the list DLL.
#  - StzValue.compare() ordered mixed int/float by tag, not value, so a float
#    inserted among ints landed at the end. Now compares numerically across
#    int/float.

Scenario("Construction sorts the items")
    Given("an unsorted list")
    o = new stzSortedList([ 2, 1, 4, 3 ])
    Then("Content is ascending", ListEq(o.Content(), [ 1, 2, 3, 4 ]), TRUE)
    Then("NumberOfItems is 4", o.NumberOfItems(), 4)
EndScenario()

Scenario("Add keeps the list sorted (was a silent no-op)")
    Given("a sorted list [1,2,4,6]")
    o = new stzSortedList([ 2, 1, 4, 6 ])
    o.Add(5)
    Then("Add(5) inserts in order -> [1,2,4,5,6]", ListEq(o.Content(), [ 1, 2, 4, 5, 6 ]), TRUE)
    o.Add(0)
    o.Add(3)
    Then("further adds stay sorted", ListEq(o.Content(), [ 0, 1, 2, 3, 4, 5, 6 ]), TRUE)
EndScenario()

Scenario("Mixed int/float ordering")
    Given("ints with a float inserted")
    o = new stzSortedList([ 1, 3, 5 ])
    o.Add(2.5)
    o.Add(4.5)
    Then("the float lands in numeric order", ListEq(o.Content(), [ 1, 2.5, 3, 4.5, 5 ]), TRUE)
EndScenario()

Scenario("Strings sort lexicographically")
    Given("words")
    o = new stzSortedList([ "banana", "apple" ])
    o.Add("cherry")
    Then("Content is alphabetical", ListEq(o.Content(), [ "apple", "banana", "cherry" ]), TRUE)
EndScenario()

Scenario("Append and the + operator are sorted inserts too")
    a = new stzSortedList([ 5, 3 ])
    a.Append(4)
    Then("Append inserts in order", ListEq(a.Content(), [ 3, 4, 5 ]), TRUE)
    b = new stzSortedList([ 5, 3 ])
    b + 4
    Then("the + operator inserts in order", ListEq(b.Content(), [ 3, 4, 5 ]), TRUE)
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
