load "../../stzBase.ring"
load "../_narrated.ring"

# UnicodeCompareWithCS speaks :Less / :Equal / :Greater.
# Archive block #826.

Scenario("Three reservations")
	Then("same word, case aside",
		Q("reserve").UnicodeCompareWithCS("RESERVE", :CaseSensitive = FALSE),
		:Equal)
	Then("accents sort after",
		Q("réservé").UnicodeCompareWithCS("RESERVE", :CaseSensitive = FALSE),
		:Greater)
	Then("a shorter prefix sorts before",
		Q("reserv").UnicodeCompareWithCS("RESERVE", :CaseSensitive = FALSE),
		:Less)
EndScenario()

Summary()
