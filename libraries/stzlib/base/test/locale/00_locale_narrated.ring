load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzLocale -- locale identity (country/
# language/abbreviation) and case mapping. Backed by stzlib's own data
# tables, so deterministic.

Scenario("Case mapping under the C locale")
    Given("the C locale")
    o = Lcl("C")
    Then("Lowercase('RING') is 'ring'", o.Lowercase("RING"), "ring")
    Then("Uppercase('ring') is 'RING'", o.Uppercase("ring"), "RING")
EndScenario()

Scenario("Identity of en_US")
    Given("the en_US locale")
    o = Lcl("en_US")
    Then("Abbreviation is en_US", o.Abbreviation(), "en_US")
    Then("CountryName is united_states", o.CountryName(), "united_states")
    Then("LanguageName is english", o.LanguageName(), "english")
EndScenario()

Scenario("Identity of fr_FR")
    Given("the fr_FR locale")
    o = Lcl("fr_FR")
    Then("Abbreviation is fr_FR", o.Abbreviation(), "fr_FR")
    Then("CountryName is france", o.CountryName(), "france")
    Then("LanguageName is french", o.LanguageName(), "french")
    Then("CountryNumber is 74", o.CountryNumber(), 74)
EndScenario()

Summary()

func Lcl cId
    return new stzLocale(cId)
