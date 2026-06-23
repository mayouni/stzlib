load "../../stzBase.ring"
load "../_narrated.ring"

# Engine stress suite for stzList -- exercises the Zig-backed list surface
# against LARGE inputs (50,000+ items) to prove the engine stays correct at
# scale: build, count, find, contains, sort, reverse, dedup, conditional
# count, sum, and set operations. Deterministic (asserts results, not timing).
# This is the large-data companion to 00_list_narrated / 01_deeplist_narrated.

# A 50k range and a 50k all-same list, reused across scenarios.
N = 50000

Scenario("Build and basic stats at scale")
    Given("the list 1..50000")
    o = Q(1:N)
    Then("NumberOfItems is 50000", o.NumberOfItems(), N)
    Then("FirstItem is 1", o.FirstItem(), 1)
    Then("LastItem is 50000", o.LastItem(), N)
    Then("Sum is N*(N+1)/2", o.Sum(), N * (N + 1) / 2)
EndScenario()

Scenario("Find and membership at scale")
    o = Q(1:N)
    Then("Find(49999) -> [49999]", ListEq(o.Find(49999), [ 49999 ]), TRUE)
    Then("Contains(50000) is TRUE", o.Contains(N), TRUE)
    Then("Contains(0) is FALSE", o.Contains(0), FALSE)
    Then("NumberOfOccurrences(1) is 1", o.NumberOfOccurrences(1), 1)
EndScenario()

Scenario("Sort and reverse at scale")
    Given("the descending list 50000..1")
    o = Q(N:1)
    s = o.Sorted()
    Then("Sorted first item is 1", s[1], 1)
    Then("Sorted last item is 50000", s[N], N)
    r = Q(1:N).Reversed()
    Then("Reversed first item is 50000", r[1], N)
    Then("Reversed last item is 1", r[N], 1)
EndScenario()

Scenario("Deduplicate at scale")
    Given("a 50000-item list of all 7s")
    od = Q( new stzList([7]) * N )
    Then("the built list has 50000 items", od.NumberOfItems(), N)
    Then("RemoveDuplicates collapses it to [7]", ListEq(od.RemoveDuplicatesQ().Content(), [ 7 ]), TRUE)
    Then("a 50000-item all-unique list dedups to 50000", Q(1:N).RemoveDuplicatesQ().NumberOfItems(), N)
EndScenario()

Scenario("Conditional count at scale (engine W)")
    o = Q(1:N)
    Then("CountW(@item > 49990) is 10", o.CountW('{ @item > 49990 }'), 10)
    Then("CountW(@item <= 100) is 100", o.CountW('{ @item <= 100 }'), 100)
EndScenario()

Scenario("Set operations at scale")
    Given("A = 1..30000 and B = 20001..50000")
    a = Q(1:30000)
    Then("UnionWith(A,B) has 50000 items", Q(a.UnionWith(20001:50000)).NumberOfItems(), 50000)
    Then("IntersectionWith(A,B) has 10000 items", Q(a.IntersectionWith(20001:50000)).NumberOfItems(), 10000)
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
