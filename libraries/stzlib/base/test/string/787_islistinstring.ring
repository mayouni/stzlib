load "../../stzBase.ring"
load "../_narrated.ring"

# IsListInString. Archive block #787.

Scenario("Strings that hold lists")
	Then("a bracketed list",
		StzStringQ("[ 2, 3, 5:7 ]").IsListInString(), TRUE)
	Then("a char range",
		StzStringQ("'A':'F'").IsListInString(), TRUE)
EndScenario()

Summary()
