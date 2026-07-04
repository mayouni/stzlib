load "../../stzBase.ring"
load "../_narrated.ring"

# IsLowercase / IsUppercase. Archive block #761.

Scenario("Two holiday strings")
	Then("happy-holidays is lowercase",
		StzStringQ("happy-holidays").IsLowercase(), TRUE)
	Then("HOLIDAYS! is uppercase",
		StzStringQ("HOLIDAYS!").IsUppercase(), TRUE)
EndScenario()

Summary()
