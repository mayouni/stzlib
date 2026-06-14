load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzListOfStrings -- the core,
# deterministic string-list operations: concatenation, counting,
# membership/find, case mapping, reverse, sort, and dedup.

Scenario("Concatenate the strings")
    Given("a 3-string list")
    o = Sl([ "ring", "programming", "languag" ])
    Then("ConcatenatedUsing(' ') joins with spaces", o.ConcatenatedUsing(" "), "ring programming languag")
    Then("an empty list concatenates to ''", Sl([ ]).ConcatenatedUsing(" "), "")
EndScenario()

Scenario("Count, membership and find")
    Given("the list [one, two, three]")
    o = Sl([ "one", "two", "three" ])
    Then("NumberOfStrings is 3", o.NumberOfStrings(), 3)
    Then("Contains('two') is TRUE", o.Contains("two"), TRUE)
    Then("Contains('zzz') is FALSE", o.Contains("zzz"), FALSE)
    Then("Find('two') -> [2]", ListEq(o.Find("two"), [ 2 ]), TRUE)
EndScenario()

Scenario("Case mapping and reversal")
    Given("the list [ring, prog, lang]")
    Then("ToUpperQ uppercases each", ListEq(Sl([ "ring", "prog", "lang" ]).ToUpperQ().Content(), [ "RING", "PROG", "LANG" ]), TRUE)
    Then("Reversed flips the order", ListEq(Sl([ "ring", "prog", "lang" ]).Reversed(), [ "lang", "prog", "ring" ]), TRUE)
EndScenario()

Scenario("Sort and deduplicate")
    Given("an unsorted, duplicate-bearing list")
    Then("SortInAscendingQ orders alphabetically", ListEq(Sl([ "banana", "apple", "cherry" ]).SortInAscendingQ().Content(), [ "apple", "banana", "cherry" ]), TRUE)
    o = Sl([ "aa", "b", "aa", "ccc", "b" ])
    o.RemoveDuplicates()
    Then("RemoveDuplicates keeps first occurrences", ListEq(o.Content(), [ "aa", "b", "ccc" ]), TRUE)
EndScenario()

Scenario("Sort by a custom key expression")
    Given("strings of varying length and a len(@string) key")
    s = Sl([ "a", "abcde", "abc", "ab", "abcd" ])
    s.SortBy('len(@string)')
    Then("SortBy orders by length with no spurious empty element", ListEq(s.Content(), [ "a", "ab", "abc", "abcd", "abcde" ]), TRUE)
    s2 = Sl([ "bbb", "a", "cc" ])
    s2.SortBy('len(@string)')
    Then("SortBy is stable on a 3-element list", ListEq(s2.Content(), [ "a", "cc", "bbb" ]), TRUE)
EndScenario()

Summary()

func Sl aList
    return new stzListOfStrings(aList)

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
