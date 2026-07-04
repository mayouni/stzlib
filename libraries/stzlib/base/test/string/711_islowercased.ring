load "../../stzBase.ring"
load "../_narrated.ring"

# ... and their checkers. Archive block #711.

Scenario("Checking the case of tunis")
	Then("tunis is lowercased", StzStringQ("tunis").IsLowercased(), TRUE)
	Then("TUNIS is uppercased", StzStringQ("TUNIS").IsUppercased(), TRUE)
	Then("Tunis is titlecased", StzStringQ("Tunis").IsTitlecased(), TRUE)
EndScenario()

Summary()
