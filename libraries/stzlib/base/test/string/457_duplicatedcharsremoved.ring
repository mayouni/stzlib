load "../../stzBase.ring"
load "../_narrated.ring"

# DuplicatedCharsRemoved does the block-#456 pipeline in one call.
# Archive block #457.

Scenario("One-call char dedup")
	Then("Riiiiinngg dedups to Ring",
		Q("Riiiiinngg").DuplicatedCharsRemoved(), "Ring")
EndScenario()

Summary()
