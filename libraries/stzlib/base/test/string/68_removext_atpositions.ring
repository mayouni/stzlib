load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(sub, :AtPositions = [...]) removes the occurrences of sub starting at
# each given codepoint position (multibyte-safe). Archive block #68.

Scenario("Removing a substring at several positions")
	Given('"♥♥♥ring ♥♥♥ruby ♥♥♥php"')
	o1 = new stzString("♥♥♥ring ♥♥♥ruby ♥♥♥php")
	o1.RemoveXT("♥♥♥", :AtPositions = [ 1, 9, 17 ])
	Then("all three heart-runs are removed", o1.Content(), "ring ruby php")
EndScenario()

Summary()
