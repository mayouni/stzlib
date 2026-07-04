load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceNthChar, positional and :With forms -- codepoint-aware (the
# accented chars count as ONE char each). Archive block #729.

Scenario("Starring the 3rd char of a French word")
	Then("positional",
		StzStringQ("évènement").ReplaceNthCharQ(3, "*").Content(), "év*nement")
	Then("named",
		StzStringQ("évènement").ReplaceNthCharQ(3, :With = "*").Content(), "év*nement")
EndScenario()

Summary()
