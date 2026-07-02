load "../../stzBase.ring"
load "../_narrated.ring"

# Both stzString and stzChar answer IsAString. Archive block #476.

Scenario("Strings and chars are strings")
	Then("a stzString is a string", StzStringQ("s").IsAString(), TRUE)
	Then("a stzChar is a string too", StzCharQ("s").IsAString(), TRUE)
EndScenario()

Summary()
