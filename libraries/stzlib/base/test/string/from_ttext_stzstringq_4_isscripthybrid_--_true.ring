load "../../stzBase.ring"
load "../_narrated.ring"

# IsScriptOf checks the dominant script: pure spaces are Common; a
# lone Arabic dhammah is Inherited. Extracted from stzTtexttest.ring,
# block #11.

Scenario("Script membership of neutral chars")
	Then("spaces are Common",
		StzStringQ("  ").IsScriptOf(:Common), TRUE)
	Then("a dhammah is Inherited",
		StzStringQ(ArabicDhammah()).IsScriptOf(:Inherited), TRUE)
EndScenario()

Summary()
