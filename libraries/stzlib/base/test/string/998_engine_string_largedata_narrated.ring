load "../../stzBase.ring"
load "../_narrated.ring"

# Engine STRESS suite for the SUBSTRING-ENUMERATION family -- the methods that
# were moved from O(n^2)/O(n^3) Ring loops into the Zig engine (SubStrings,
# SubStringsCS/U, DuplicatesCS, the occurrence family, ConsecutiveSubStrings,
# FindDupSecutiveChars). Deterministic -- asserts results, not timing.
#
# These operations are inherently Theta(n^2) in OUTPUT (an n-char string has
# n(n+1)/2 substrings), so they are stressed at MODERATE length (100 .. 1000),
# NOT at millions. At L=1000 that is 500,500 substrings enumerated + drained in
# ~1s -- the old per-substring Ring loop (with an engine round-trip per slice)
# took minutes for the same work. The MILLION-scale LINEAR ops live in
# 999_engine_string_millions_narrated.ring.
#
# Reference counts for the uniform string "a" repeated L times:
#   NumberOfSubStrings = L(L+1)/2 ; distinct (SubStringsU) = L ;
#   DuplicatesCS(1) = floor(L/2) (a^k with non-overlapping count >= 2 <=> k<=L/2);
#   FindDupSecutiveChars = L-1 (every char equals the one before it).
# Literal counts are used on purpose (a numeric global n/N is clobbered by
# shared engine globals -- Ring is case-insensitive).

oA = new stzString("a")

Scenario("SubStrings enumeration at L=1000 (500,500 substrings, engine)")
    s = new stzString( oA.Repeated(1000) )
    Then("NumberOfSubStrings is 500,500 (L(L+1)/2)", s.NumberOfSubStrings(), 500500)
    Then("SubStrings() enumerates all 500,500", len(s.SubStrings()), 500500)
    Then("SubStringsU() distinct is 1,000 (a^1..a^1000)", len(s.SubStringsU()), 1000)
EndScenario()

Scenario("Duplicates & occurrence filters at L=1000 (engine)")
    s = new stzString( oA.Repeated(1000) )
    Then("DuplicatesCS(1) is 500 (a^k, k<=500)", len(s.DuplicatesCS(1)), 500)
    Then("SubStringsOccuringNTimes(2) is 500 (count >= 2)", len(s.SubStringsOccuringNTimes(2)), 500)
    Then("SubStringsOccurringOnlyNTimes(1) is 500 (count == 1)", len(s.SubStringsOccurringOnlyNTimes(1)), 500)
EndScenario()

Scenario("Consecutive substrings & dup-consecutive chars at L=1000 (engine)")
    s = new stzString( oA.Repeated(1000) )
    Then("ConsecutiveSubStrings count is 375,250", len(s.ConsecutiveSubStrings()), 375250)
    Then("FindDupSecutiveChars is 999 (positions 2..1000)", len(s.FindDupSecutiveChars()), 999)
EndScenario()

Scenario("Case-sensitivity dial holds at scale -- 'aA' repeated 50 (100 chars)")
    m = new stzString("aA")
    big = new stzString( m.Repeated(50) )
    Then("SubStringsCS(1) exact-distinct is 199", len(big.SubStringsCS(1)), 199)
    Then("SubStringsU() folds all case -> 100 (like a^100)", len(big.SubStringsU()), 100)
    Then("DuplicatesCS(1) exact is 99", len(big.DuplicatesCS(1)), 99)
    Then("DuplicatesCS(0) case-insensitive dedup is 50", len(big.DuplicatesCS(0)), 50)
EndScenario()

Scenario("Broad family sanity at L=100 (uniform 'a')")
    s = new stzString( oA.Repeated(100) )
    Then("NumberOfSubStrings is 5,050", s.NumberOfSubStrings(), 5050)
    Then("SubStrings() enumerates 5,050", len(s.SubStrings()), 5050)
    Then("SubStringsU() is 100", len(s.SubStringsU()), 100)
    Then("DuplicatesCS(1) is 50", len(s.DuplicatesCS(1)), 50)
    Then("ConsecutiveSubStrings is 3,775", len(s.ConsecutiveSubStrings()), 3775)
    Then("FindDupSecutiveChars is 99", len(s.FindDupSecutiveChars()), 99)
EndScenario()

Summary()
