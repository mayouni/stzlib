load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzRegex -- the PCRE2-backed engine.
# Covers the core full-match surface (Match / AllMatches / NumberOfMatches)
# with digit classes, quantifiers, anchors and alternation. Deterministic.
# (The partial-match helpers MatchAsYouType/MatchInProgress are NOT covered
#  here -- they currently return FALSE for inputs the classic tests expect
#  TRUE, i.e. partial matching looks unwired; left out rather than locking
#  broken behavior.)

Scenario("Match presence/absence")
    Then("\\d+ matches a string containing digits", Rgx("\d+").Match("total 42 here"), TRUE)
    Then("\\d+ does not match a digitless string", Rgx("\d+").Match("no digits here"), FALSE)
EndScenario()

Scenario("All matches in a string")
    Given("the pattern \\d+ run over 'a1b22c333'")
    o = Rgx("\d+")
    o.Match("a1b22c333")
    Then("AllMatches collects each run of digits", ListEq(o.AllMatches(), [ "1", "22", "333" ]), TRUE)
    Then("NumberOfMatches is 3", o.NumberOfMatches(), 3)
EndScenario()

Scenario("Character classes")
    Given("the pattern [a-z]+ over 'the quick fox'")
    o = Rgx("[a-z]+")
    o.Match("the quick fox")
    Then("it extracts the words", ListEq(o.AllMatches(), [ "the", "quick", "fox" ]), TRUE)
EndScenario()

Scenario("Anchors and exact quantifiers")
    Then("^\\d{3}$ matches exactly 3 digits", Rgx("^\d{3}$").Match("123"), TRUE)
    Then("^\\d{3}$ rejects 4 digits", Rgx("^\d{3}$").Match("1234"), FALSE)
EndScenario()

Scenario("Capture group extraction")
    Given("the captured number pattern (\\d+)")
    o = Rgx("(\d+)")
    o.Match("The total was 42 dollars and 13 cents.")
    Then("AllMatches returns the captured numbers", ListEq(o.AllMatches(), [ "42", "13" ]), TRUE)
EndScenario()

Summary()

func Rgx cPattern
    return new stzRegex(cPattern)

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
