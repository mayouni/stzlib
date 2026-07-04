load "../../stzBase.ring"
load "../_narrated.ring"

# A bare language code is not a locale; lang-COUNTRY is. And the
# stzLocale side can name the country. Archive block #842.

Scenario("fr alone, then fr-fr")
	Then("fr alone is not a locale",
		Q("fr").IsLocaleAbbreviation(), FALSE)
	Then("fr-fr is", Q("fr-fr").IsLocaleAbbreviation(), TRUE)
	Then("and its country reads france",
		StzLocaleQ("fr-fr").Country(), "france")
EndScenario()

Summary()
