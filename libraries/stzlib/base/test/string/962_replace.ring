load "../../stzBase.ring"
load "../_narrated.ring"

# The global StzReplace. Archive block #962.

Scenario("Dashes to spaces")
	Then("replaced everywhere",
		StzReplace("--^---^^--^", "-", " "), "  ^   ^^  ^")
EndScenario()

Summary()
