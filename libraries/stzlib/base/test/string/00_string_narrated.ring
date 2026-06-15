load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzString -- a representative core of
# the engine-backed (Unicode-correct) string surface: case, length,
# reverse, search, replace, split, trim, slicing. Not exhaustive (the
# domain has ~970 classic blocks); this is the run-for-real safety net for
# the central operations. Deterministic. Objects via Q(...).

Scenario("Case mapping")
    Then("Uppercased('ring') is RING", Q("ring").Uppercased(), "RING")
    Then("Lowercased('RING') is ring", Q("RING").Lowercased(), "ring")
EndScenario()

Scenario("Length is codepoint-correct")
    Then("NumberOfChars('softanza') is 8", Q("softanza").NumberOfChars(), 8)
    Then("NumberOfChars('héllo') is 5 (not byte count)", Q("héllo").NumberOfChars(), 5)
EndScenario()

Scenario("Reverse and search")
    Then("Reversed('abc') is cba", Q("abc").Reversed(), "cba")
    Then("Contains('tan') in 'softanza'", Q("softanza").Contains("tan"), TRUE)
    Then("Contains('xyz') is FALSE", Q("softanza").Contains("xyz"), FALSE)
    Then("FindFirst('a') is position 5", Q("softanza").FindFirst("a"), 5)
EndScenario()

Scenario("Replace and split")
    Then("Replaced swaps all occurrences", Q("aXbXc").Replaced("X", "-"), "a-b-c")
    Then("Split on ',' yields the parts", ListEq(Q("a,b,c").Split(","), [ "a", "b", "c" ]), TRUE)
EndScenario()

Scenario("Trim, equality and slicing")
    Then("Trimmed strips surrounding spaces", Q("  hi  ").Trimmed(), "hi")
    Then("IsEqualTo matches identical strings", Q("abc").IsEqualTo("abc"), TRUE)
    Then("FirstNChars(3) of 'softanza' is 'sof'", Q("softanza").FirstNChars(3), "sof")
    Then("LastNChars(3) of 'softanza' is 'nza'", Q("softanza").LastNChars(3), "nza")
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
