load "../../stzBase.ring"
load "../_narrated.ring"

# IsScriptName. Archive block #838.

Scenario("latin is a script name")
	Then("yes", StzStringQ("latin").IsScriptName(), TRUE)
EndScenario()

Summary()
