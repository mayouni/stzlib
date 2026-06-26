load "../../stzBase.ring"
load "../_narrated.ring"

# Script() detects the writing system of a string. TQ() is a text-string Q
# helper. Archive block #108.

Scenario("Detecting the script of a string")
	Given("a Hebrew word")
	Then("its script is hebrew", TQ("משמש").Script(), "hebrew")
EndScenario()

Summary()
