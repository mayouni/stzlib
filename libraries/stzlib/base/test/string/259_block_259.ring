load "../../stzBase.ring"
load "../_narrated.ring"

# Ring's own substr edge cases -- documenting the platform behavior
# Softanza builds on. Archive block #259.

Scenario("Ring substr at the edges")
	Then("empty haystack slices to empty", substr("", 1, 1), "")
	Then("empty needle is found at 1", substr("blablabla", ""), 1)
	Then("ring_substr1 of empty needle is 0",
		ring_substr1("blablabla", ""), 0)
EndScenario()

Summary()
