load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzChar / stzStringChar -- a single
# Unicode character: name <-> codepoint, case mapping, and category
# predicates. Driven by codepoints and Unicode NAMES so console output
# stays ASCII (no raw glyphs in labels).

Scenario("Name and codepoint round-trip")
    Then("char 65 is named LATIN CAPITAL LETTER A", Chr(65).Name(), "LATIN CAPITAL LETTER A")
    Then("'A' has codepoint 65", Chr("A").Unicode(), 65)
    Then("codepoint 9885 is OUTLINED WHITE STAR", Chr(9885).Name(), "OUTLINED WHITE STAR")
    Then("the named star resolves back to 9885", Chr("OUTLINED WHITE STAR").Unicode(), 9885)
EndScenario()

Scenario("Case mapping")
    Then("Lowercased('A') is 'a'", Chr("A").Lowercased(), "a")
    Then("Uppercased('a') is 'A'", Chr("a").Uppercased(), "A")
    Then("IsUppercase('A') is TRUE", Chr("A").IsUppercase(), TRUE)
    Then("IsLowercase('a') is TRUE", Chr("a").IsLowercase(), TRUE)
EndScenario()

Scenario("Category predicates")
    Then("'A' is a letter", Chr("A").IsLetter(), TRUE)
    Then("'A' is not a digit", Chr("A").IsDigit(), FALSE)
    Then("'5' is a digit", Chr("5").IsDigit(), TRUE)
    Then("space is whitespace", Chr(" ").IsSpace(), TRUE)
    Then("'!' is punctuation", Chr("!").IsPunctuation(), TRUE)
EndScenario()

Scenario("Vowel detection")
    Given("the IsVowel predicate (regression: it always returned FALSE)")
    Then("'a' is a vowel", Chr("a").IsVowel(), TRUE)
    Then("'A' is a vowel (case-insensitive)", Chr("A").IsVowel(), TRUE)
    Then("'e' is a vowel", Chr("e").IsVowel(), TRUE)
    Then("'b' is not a vowel", Chr("b").IsVowel(), FALSE)
    Then("'5' is not a vowel", Chr("5").IsVowel(), FALSE)
EndScenario()

Summary()

func Chr p
    return StzCharQ(p)
