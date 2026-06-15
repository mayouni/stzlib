load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for Plural() (English pluralisation).
#
# Regression guard: the rule engine appended the suffix to the WHOLE match
# instead of the captured stem -- CapturedValues() returns [fullMatch, group1]
# and the \1 placeholder was mapped to the full match, so "city"+"ies" became
# "cityies". Fixed to map \1 -> the first capture group: city -> cities.

Scenario("Regular plurals")
    Given("simple nouns")
    Then("cat -> cats", Plural("cat"), "cats")
    Then("dog -> dogs", Plural("dog"), "dogs")
    Then("day -> days (vowel + y keeps y)", Plural("day"), "days")
EndScenario()

Scenario("Morphological stem rewrites (the previously-broken path)")
    Given("nouns whose stem changes")
    Then("city -> cities (y -> ies)", Plural("city"), "cities")
    Then("baby -> babies", Plural("baby"), "babies")
    Then("box -> boxes (x -> xes)", Plural("box"), "boxes")
    Then("church -> churches (ch -> ches)", Plural("church"), "churches")
    Then("leaf -> leaves (f -> ves)", Plural("leaf"), "leaves")
    Then("knife -> knives (fe -> ves)", Plural("knife"), "knives")
EndScenario()

Scenario("Irregular and unchanged plurals")
    Given("special nouns")
    Then("child -> children", Plural("child"), "children")
    Then("man -> men", Plural("man"), "men")
    Then("sheep -> sheep (unchanged)", Plural("sheep"), "sheep")
EndScenario()

Summary()
