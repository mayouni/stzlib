load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzCurrency (constructed from a country
# name). Data comes from the stzlib locale tables; ids are StzLower-normalised.
#
# Regression guards (all fixed this session):
#  - Currency()/Name() returned a single CHARACTER: the code indexed
#    aCountryInfo[7][1] (first char of the currency-name string) instead of
#    [7] (the whole name). Now full names: russian_ruble, euro, ...
#  - Abbreviation() crashed R2 for shared-currency countries (France/Germany
#    share "euro"): Country() reverse-mapped currency->country ambiguously.
#    init() now remembers the originating country (@cCountry@) so Country()
#    and the locale-abbreviation lookup are exact.

Scenario("A country with a unique currency (Russia)")
    Given("new stzCurrency(:Russia)")
    o = new stzCurrency(:Russia)
    Then("Currency() is the full name russian_ruble (not 'r')", o.Currency(), "russian_ruble")
    Then("Name() mirrors Currency()", o.Name(), "russian_ruble")
    Then("Abbreviation() is the ISO code RUB", o.Abbreviation(), "RUB")
    Then("Country() is russia", o.Country(), "russia")
    Then("FractionalUnit() is Kopek", o.FractionalUnit(), "Kopek")
    Then("Base() is 100", o.Base(), 100)
EndScenario()

Scenario("The United States")
    Given("new stzCurrency(:united_states)")
    o = new stzCurrency(:united_states)
    Then("Currency() is united_states_dollar", o.Currency(), "united_states_dollar")
    Then("Abbreviation() is USD", o.Abbreviation(), "USD")
    Then("Country() is united_states", o.Country(), "united_states")
EndScenario()

Scenario("Shared currency stays country-exact (France vs Germany, both euro)")
    Given("two euro countries")
    f = new stzCurrency(:France)
    g = new stzCurrency(:Germany)
    Then("France Currency() is euro", f.Currency(), "euro")
    Then("France Abbreviation() is EUR (no longer R2)", f.Abbreviation(), "EUR")
    Then("France Country() is france (not another euro country)", f.Country(), "france")
    Then("Germany Country() is germany (distinct from France)", g.Country(), "germany")
    Then("Germany Abbreviation() is EUR too", g.Abbreviation(), "EUR")
EndScenario()

Scenario("Japan")
    Given("new stzCurrency(:Japan)")
    o = new stzCurrency(:Japan)
    Then("Currency() is japanese_yen", o.Currency(), "japanese_yen")
    Then("Abbreviation() is JPY", o.Abbreviation(), "JPY")
EndScenario()

Summary()
