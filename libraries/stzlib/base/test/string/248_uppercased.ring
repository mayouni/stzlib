load "../../stzBase.ring"
load "../_narrated.ring"

# Uppercased() returns the upper-cased string; IsUppercase() tests it. Archive #248.

Scenario("Upper-casing a string")
	Then("Uppercased raises the case",
		Q("i believe in ring future and engage for it!").Uppercased(),
		"I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!")
	Then("the all-caps string IS uppercase",
		Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").IsUppercase(), TRUE)
EndScenario()

Summary()
