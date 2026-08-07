load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzRegex -- the PCRE2-backed engine.
#
# Match() ANCHORS. It asks whether the pattern matches the string ENTIRELY,
# which is what :MatchEntireContent has always claimed to mean. The search --
# "does this occur anywhere in here" -- is MatchFirst(). Two questions, two
# methods; the old code answered the second one under the first one's name.
#
# The partial-match helpers used to be excluded from this file with a note
# saying they "return FALSE for inputs the classic tests expect TRUE, i.e.
# partial matching looks unwired". It was: MatchXT validated the match type
# and then ignored it, so every type ran the same unanchored search. The
# types are wired now, so the helpers are covered here.

Scenario("Match ANCHORS, MatchFirst SEARCHES")
    Then("\\d+ does NOT match a string that merely contains digits", Rgx("\d+").Match("total 42 here"), FALSE)
    Then("...but MatchFirst finds it", Rgx("\d+").MatchFirst("total 42 here"), TRUE)
    Then("\\d+ matches a string that is entirely digits", Rgx("\d+").Match("42"), TRUE)
    Then("\\d+ does not match a digitless string", Rgx("\d+").MatchFirst("no digits here"), FALSE)
EndScenario()

Scenario("All matches in a string")
    Given("the pattern \\d+ run over 'a1b22c333'")
    o = Rgx("\d+")
    o.MatchFirst("a1b22c333")
    Then("AllMatches collects each run of digits", ListEq(o.AllMatches(), [ "1", "22", "333" ]), TRUE)
    Then("NumberOfMatches is 3", o.NumberOfMatches(), 3)
EndScenario()

Scenario("Character classes")
    Given("the pattern [a-z]+ over 'the quick fox'")
    o = Rgx("[a-z]+")
    o.MatchFirst("the quick fox")
    Then("it extracts the words", ListEq(o.AllMatches(), [ "the", "quick", "fox" ]), TRUE)
EndScenario()

Scenario("Anchors and exact quantifiers")
    Then("^\\d{3}$ matches exactly 3 digits", Rgx("^\d{3}$").Match("123"), TRUE)
    Then("^\\d{3}$ rejects 4 digits", Rgx("^\d{3}$").Match("1234"), FALSE)
EndScenario()

Scenario("Capture group extraction")
    Given("the captured number pattern (\\d+)")
    o = Rgx("(\d+)")
    o.MatchFirst("The total was 42 dollars and 13 cents.")
    Then("AllMatches returns the captured numbers", ListEq(o.AllMatches(), [ "42", "13" ]), TRUE)
EndScenario()

Scenario("The four match types now differ")
    Given("the pattern [0-9]+ against 'abc123'")
    Then("entire content: no, 'abc123' is not a run of digits",
         Rgx("[0-9]+").MatchXT("abc123", 1, :MatchEntireContent, []), 0)
    Then("first occurrence: yes, one is in there",
         Rgx("[0-9]+").MatchXT("abc123", 1, :MatchFirstOccurrenceIfNotGoPartial, []), 1)
    Then("return-false-for-any-match: the engine is off",
         Rgx("[0-9]+").MatchXT("123", 1, :ReturnFalseForAnyMatch, []), 0)
    Then("...even though the same subject matches entirely",
         Rgx("[0-9]+").MatchXT("123", 1, :MatchEntireContent, []), 1)
EndScenario()

Scenario("Partial matching -- as you type")
    Given("the SSN pattern ^\\d{3}-\\d{2}-\\d{4}$")
    Then("'123' is on the way", Rgx("^\d{3}-\d{2}-\d{4}$").MatchAsYouType("123"), TRUE)
    Then("'123-45' is on the way", Rgx("^\d{3}-\d{2}-\d{4}$").MatchAsYouType("123-45"), TRUE)
    Then("'123-45-6789' has arrived", Rgx("^\d{3}-\d{2}-\d{4}$").MatchAsYouType("123-45-6789"), TRUE)
    Then("'abc' cannot get there from here", Rgx("^\d{3}-\d{2}-\d{4}$").MatchAsYouType("abc"), FALSE)
    Then("a partial is NOT a complete match", Rgx("^\d{3}-\d{2}-\d{4}$").IsPartialMatch("123-45"), TRUE)
    Then("...and a complete one is not partial", Rgx("^\d{3}-\d{2}-\d{4}$").IsPartialMatch("123-45-6789"), FALSE)
EndScenario()

Scenario("Z hands back positions; it does not print them")

	# The library documents Z() and ZZ() as DATA suffixes: both answer positions,
	# the first as numbers, the second as sections. Every other ...Z() in the
	# library returns.
	#
	# MatchesZ() printed @@(FindMatches()) and returned nothing -- so it answered
	# NULL while dumping to the console, and so did its four aliases, every one of
	# them named ...AndTheirPositions. Nothing in the family carried a position at
	# all. A code rule found it: a library reports through its return value.

	Given("three runs of digits in a string")
	oRx = new stzRegex("[0-9]+")
	oRx.MatchXT("a12b345c6", 1, :MatchFirstOccurrenceIfNotGoPartial, [])

	Then("Matches gives the values", @@(oRx.Matches()), '[ "12", "345", "6" ]')

	# Z: each value WITH its position, the position as a number.
	Then("MatchesZ gives value and position", @@(oRx.MatchesZ()), '[ [ "12", 2 ], [ "345", 5 ], [ "6", 9 ] ]')
	Then("...as DATA, not as console output", isList(oRx.MatchesZ()), TRUE)
	Then("...one entry per match", len(oRx.MatchesZ()), 3)

	# THE NEGATIVE SIBLING: ZZ must stay different, or Z could simply be ZZ under
	# another name and the assertion above would prove nothing.
	Then("ZZ gives the position as a SECTION instead", @@(oRx.MatchesZZ()), '[ [ "12", [ 2, 4 ] ], [ "345", [ 5, 8 ] ], [ "6", [ 9, 10 ] ] ]')

	# ...and the four aliases were the reason this mattered: they are the names a
	# caller actually reaches for.
	Then("ValuesAndTheirPositions agrees", @@(oRx.ValuesAndTheirPositions()), @@(oRx.MatchesZ()))
	Then("...and so does MatchesAndTheirPositions", @@(oRx.MatchesAndTheirPositions()), @@(oRx.MatchesZ()))
	Then("...and it is not empty", len(oRx.MatchingSubStringsAndTheirPositions()), 3)
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
