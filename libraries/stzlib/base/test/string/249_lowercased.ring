load "../../stzBase.ring"
load "../_narrated.ring"

# Lowercased() returns the lower-cased string; IsLowercase() tests it. Archive #249.

Scenario("Lower-casing a string")
	Then("Lowercased drops the case",
		Q("I BELIEVE IN RING FUTURE AND ENGAGE FOR IT!").Lowercased(),
		"i believe in ring future and engage for it!")
	Then("the all-lower string IS lowercase",
		Q("i believe in ring future and engage for it!").IsLowercase(), TRUE)
EndScenario()

Summary()
