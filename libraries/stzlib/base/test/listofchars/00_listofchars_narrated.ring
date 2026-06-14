load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzListOfChars. The class is built
# from Unicode codepoints; to keep console output ASCII-clean the suite
# asserts on codepoints (Unicodes) rather than the rendered glyphs.

Scenario("Build a char list from codepoints")
    Given("the Greek letters alpha/beta/gamma as [945,946,947]")
    o = Lchr([ 945, 946, 947 ])
    Then("NumberOfChars is 3", o.NumberOfChars(), 3)
    Then("Unicodes round-trips the codepoints", ListEq(o.Unicodes(), [ 945, 946, 947 ]), TRUE)
    Then("Unicodes(Content()) re-derives them", ListEq(Unicodes(o.Content()), [ 945, 946, 947 ]), TRUE)
EndScenario()

Scenario("Build a char list from a char range")
    Given("the range 'A':'E'")
    q = StzListOfCharsQ("A":"E")
    Then("NumberOfChars is 5", q.NumberOfChars(), 5)
    Then("Unicodes are [65..69]", ListEq(q.Unicodes(), [ 65, 66, 67, 68, 69 ]), TRUE)
EndScenario()

Scenario("Count unique characters")
    Given("a list with duplicates [A,A,B,C,C,C]")
    d = Lchr([ 65, 65, 66, 67, 67, 67 ])
    Then("NumberOfChars counts every char (6)", d.NumberOfChars(), 6)
    Then("NumberOfUniqueChars counts distinct (3)", d.NumberOfUniqueChars(), 3)
EndScenario()

Summary()

func Lchr aList
    return new stzListOfChars(aList)

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
