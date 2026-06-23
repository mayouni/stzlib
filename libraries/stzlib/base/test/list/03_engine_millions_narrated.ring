load "../../stzBase.ring"
load "../_narrated.ring"

# Engine STRESS suite at LARGE scale (hundreds of thousands to a million),
# across varied structures (numbers, repeated strings, nested sub-lists) and
# many engine functions (search, count, pattern-match, replace, sort, reverse,
# dedup). Deterministic -- asserts results, not timing.
#
# Large lists are built ENGINE-SIDE (range and .Repeated(), via the bulk
# marshal/unmarshal bridges) -- never the Ring-loop "*" operator. It guards:
#   * find returns ALL matches even when there are > 65536 of them (the old
#     fixed 65536-element bridge buffer used to overflow / cap),
#   * nested-list find uses the native stzValue structural compare (the old
#     path stringified every item -- ~16s at a million; now no stringify),
#   * engine->Ring unmarshal is one bulk call (no per-item FFI storm).
#
# Scale note: ops re-marshal the list per call (lists are not yet engine-
# resident), and Union/Intersection/Classify are still O(n*m)/O(n^2). So the
# bulk runs at N=200,000 (already > 65536, proving the buffer fix) with a
# single 1,000,000 headline. See memory for the remaining engine-residency
# and hash-based set-ops/classify work.

N = 200000        # main scale (> 65536, so it exercises the old cap)
M = 1000000       # one-million headline

# --- shared big lists, built once, engine-side ---
oNum = Q(1:N)
aAB  = Q([ "a", "b" ]).Repeated(N / 2)     # N items: "a" and "b" each N/2 times

Scenario("Large numeric list: stats, find, membership")
    Then("NumberOfItems is 200,000", oNum.NumberOfItems(), N)
    Then("Sum is N*(N+1)/2", oNum.Sum(), N * (N + 1) / 2)
    Then("FirstItem is 1", oNum.FirstItem(), 1)
    Then("LastItem is 200,000", oNum.LastItem(), N)
    Then("Contains(200000) is TRUE", oNum.Contains(N), TRUE)
    Then("Find(199999) -> [199999]", ListEq(oNum.Find(199999), [ 199999 ]), TRUE)
EndScenario()

Scenario("Search & pattern matching (engine W)")
    Then("CountW(@item > 199990) is 10", oNum.CountW('{ @item > 199990 }'), 10)
    Then("FindW(@item > 199000) finds 1000 positions", len(oNum.FindW('{ @item > 199000 }')), 1000)
EndScenario()

Scenario("Find returns ALL matches when there are MORE than 65536")
    o = Q(aAB)
    Then("FindAll(a) returns all 100,000 (> 65536 -- old buffer cap)", len(o.FindAll("a")), N / 2)
    Then("NumberOfOccurrences(a) is 100,000", o.NumberOfOccurrences("a"), N / 2)
EndScenario()

Scenario("A MILLION-match find (headline)")
    Given("a single value repeated a million times, engine-side")
    oBig = Q(Q([ "x" ]).Repeated(M))
    Then("FindAll(x) returns all 1,000,000 positions", len(oBig.FindAll("x")), M)
EndScenario()

Scenario("Replace and dedup")
    o = Q(aAB)
    o.Replace("a", "A")
    Then("after Replace, a is gone", o.NumberOfOccurrences("a"), 0)
    Then("after Replace, A is 100,000", o.NumberOfOccurrences("A"), N / 2)
    Then("RemoveDuplicates collapses to 2", Q(aAB).RemoveDuplicatesQ().NumberOfItems(), 2)
EndScenario()

Scenario("Nested sub-lists: native value find (no stringify)")
    Given("[1,2] repeated engine-side 100,000 times")
    aNest = Q([ [1, 2] ]).Repeated(100000)
    o = Q(aNest)
    Then("FindAll([1,2]) finds all 100,000", len(o.FindAll([ 1, 2 ])), 100000)
    Then("RemoveDuplicates collapses to one sub-list", Q(aNest).RemoveDuplicatesQ().NumberOfItems(), 1)
EndScenario()

Scenario("Sort and reverse (engine, O(n log n))")
    s = Q(N:1).Sorted()
    Then("Sorted(N..1) first is 1", s[1], 1)
    Then("Sorted last is N", s[N], N)
    r = Q(1:N).Reversed()
    Then("Reversed first is N / last is 1", ListEq([ r[1], r[N] ], [ N, 1 ]), TRUE)
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
