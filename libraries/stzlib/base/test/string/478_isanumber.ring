load "../../stzBase.ring"
load "../_narrated.ring"

# Number predicates through Q. Archive block #478.

Scenario("2 is an even positive number")
	Then("a number", Q(2).IsANumber(), TRUE)
	Then("even", Q(2).IsEven(), TRUE)
	Then("positive", Q(2).IsPositive(), TRUE)
EndScenario()

Summary()
