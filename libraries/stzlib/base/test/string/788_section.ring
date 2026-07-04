load "../../stzBase.ring"
load "../_narrated.ring"

# Section by positions. Archive block #788.

Scenario("The middle third")
	Then("456", StzStringQ("123456789").Section(4, 6), "456")
EndScenario()

Summary()
