load "../../stzBase.ring"
load "../_narrated.ring"

# IsAnagramOfCS with the case dial. Archive block #640.

Scenario("Arc vs cra")
	Then("anagrams, case aside",
		StzStringQ("Arc").IsAnagramOfCS("cra", :CS = FALSE), TRUE)
EndScenario()

Summary()
