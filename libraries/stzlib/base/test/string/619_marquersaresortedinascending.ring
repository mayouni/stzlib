load "../../stzBase.ring"
load "../_narrated.ring"

# Are the marquers' numbers ascending in text order? Archive block #619.

Scenario("Ascending or not")
	Then("1-2-3 ascends",
		Q("My name is #1, my age is #2, and my job is #3.").MarquersAreSortedInAscending(), TRUE)
	Then("2-1-3 does not",
		Q("My name is #2, my age is #1, and my job is #3.").MarquersAreSortedInAscending(), FALSE)
EndScenario()

Summary()
