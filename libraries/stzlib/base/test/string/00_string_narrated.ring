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
    Then("FindNext('a',5) finds the next 'a' at 8", Q("softanza").FindNext("a", 5), 8)
    Then("FindNext('abc',2) on 'abcabc' is 4 (was broken)", Q("abcabc").FindNext("abc", 2), 4)
EndScenario()

Scenario("Replace and split")
    Then("Replaced swaps all occurrences", Q("aXbXc").Replaced("X", "-"), "a-b-c")
    Then("Replaced is codepoint-correct on multibyte input", Q("naïve").Replaced("ï", "i"), "naive")
    Then("Replaced rewrites a multibyte target char", Q("café").Replaced("é", "e"), "cafe")
    Then("Split on ',' yields the parts", ListEq(Q("a,b,c").Split(","), [ "a", "b", "c" ]), TRUE)
EndScenario()

Scenario("Trim, equality and slicing")
    Then("Trimmed strips surrounding spaces", Q("  hi  ").Trimmed(), "hi")
    Then("IsEqualTo matches identical strings", Q("abc").IsEqualTo("abc"), TRUE)
    Then("FirstNChars(3) of 'softanza' is 'sof'", Q("softanza").FirstNChars(3), "sof")
    Then("LastNChars(3) of 'softanza' is 'nza'", Q("softanza").LastNChars(3), "nza")
EndScenario()

Scenario("Section ops are codepoint-correct (multibyte)")
    Given("strings with accented characters")
    u = new stzString("café x")
    u.UppercaseSubStringXT(1, 4)
    Then("UppercaseSubString uppercases the accented section -> CAFE-acute x", u.Content(), "CAF" + Chr0xC9() + " x")
    r = new stzString("déjà xx")
    r.ReplaceInSection(1, 7, "x", "Y")
    Then("ReplaceInSection rewrites within a codepoint range", r.Content(), "d" + Chr0xE9() + "j" + Chr0xE0() + " YY")
    a = new stzString("abcdef")
    a.ReplaceInSection(1, 3, "b", "Z")
    Then("ReplaceInSection still correct on ASCII", a.Content(), "aZcdef")
    u2 = new stzString("ab cd ab")
    u2.UppercaseSubString("ab")
    Then("UppercaseSubString(ASCII) uppercases every occurrence", u2.Content(), "AB cd AB")
    u3 = new stzString("caf" + Chr0xE9() + " caf" + Chr0xE9())
    u3.UppercaseSubString("caf" + Chr0xE9())
    Then("UppercaseSubString(multibyte) uppercases the accent too", u3.Content(), "CAF" + Chr0xC9() + " CAF" + Chr0xC9())
    t = new stzString("hello" + Chr0xE9())
    t.RemoveThisTrailingChar(Chr0xE9())
    Then("RemoveThisTrailingChar removes a multibyte trailing char", t.Content(), "hello")
    l = new stzString(Chr0xE9() + Chr0xE9() + "hi")
    l.RemoveThisLeadingChar(Chr0xE9())
    Then("RemoveThisLeadingChar removes repeated multibyte leading chars", l.Content(), "hi")
    bx = new stzString("caf" + Chr0xE9())
    Then("Boxify bar width counts codepoints, not bytes", StzLen(BoxTopBar(bx.Boxify())), 8)
    bd = new stzString("a" + Chr0xE9() + "X" + Chr0xE9() + "b")
    Then("BoundsOfXT caps the prefix/suffix by codepoints", ListEq(bd.BoundsOfXT("X", [ 1, 1 ]), [ Chr0xE9(), Chr0xE9() ]), TRUE)
EndScenario()

Summary()

func BoxTopBar cBox   # first line of a Boxify() result
    return @split(cBox, char(10))[1]

func Chr0xC9   # 'É' U+00C9
    return char(195) + char(137)

func Chr0xE9   # 'é' U+00E9
    return char(195) + char(169)

func Chr0xE0   # 'à' U+00E0
    return char(195) + char(160)

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
