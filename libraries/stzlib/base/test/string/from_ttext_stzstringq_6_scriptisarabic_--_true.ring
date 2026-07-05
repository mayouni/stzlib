load "../../stzBase.ring"
load "../_narrated.ring"

# ScriptIs matches the dominant script by name, across scripts.
# Extracted from stzTtexttest.ring, block #7.

Scenario("Naming the script")
	Then("Peace is Latin", StzStringQ("Peace").ScriptIs(:Latin), TRUE)
	Then("the Han word is Han", StzStringQ("和平").ScriptIs(:Han), TRUE)
	Then("the Gujarati word is Gujarati",
		StzStringQ("શાંતિ").ScriptIs(:Gujarati), TRUE)
EndScenario()

Summary()
