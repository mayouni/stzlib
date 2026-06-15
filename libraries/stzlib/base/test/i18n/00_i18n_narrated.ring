load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for the i18n layer -- stzLanguage and
# stzCountry, backed by stzlib's own data tables (deterministic). Country
# names are normalised to lowercase.

Scenario("Language lookup by code")
    Then("'105' is recognised as a language number", (new stzString("105")).IsLanguageNumber(), TRUE)
    Then("language 105 is sindhi", StzLanguageQ("105").Name(), "sindhi")
    Then("its default country is pakistan", StzLanguageQ("105").DefaultCountry(), "pakistan")
EndScenario()

Scenario("Country by name")
    Given("France")
    o = new stzCountry("France")
    Then("Name() is france", o.Name(), "france")
    Then("Abbreviation() is FR", o.Abbreviation(), "FR")
EndScenario()

Scenario("Country by abbreviation")
    Given("the US abbreviation")
    u = new stzCountry("US")
    Then("Name() resolves to united_states", u.Name(), "united_states")
    Then("Abbreviation() is US", u.Abbreviation(), "US")
EndScenario()

Summary()
