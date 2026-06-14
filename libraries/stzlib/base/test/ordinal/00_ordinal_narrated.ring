load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for Ordinal() -- localized ordinal
# numbers (English + French).

Scenario("English ordinals")
    Given("English ordinal language")
    SetOrdinalLanguage("en")
    Then("1 -> 1st",  Ordinal(1), "1st")
    Then("2 -> 2nd",  Ordinal(2), "2nd")
    Then("3 -> 3rd",  Ordinal(3), "3rd")
    Then("4 -> 4th",  Ordinal(4), "4th")
    Then("11 -> 11th (teens are th)", Ordinal(11), "11th")
    Then("12 -> 12th", Ordinal(12), "12th")
    Then("13 -> 13th", Ordinal(13), "13th")
    Then("21 -> 21st", Ordinal(21), "21st")
    Then("22 -> 22nd", Ordinal(22), "22nd")
    Then("23 -> 23rd", Ordinal(23), "23rd")
EndScenario()

Scenario("French ordinals")
    Given("French ordinal language")
    SetOrdinalLanguage("fr")
    Then("1 -> 1er", Ordinal(1), "1er")
    Then("2 -> 2e",  Ordinal(2), "2e")
    SetOrdinalLanguage("en")
EndScenario()

Summary()
