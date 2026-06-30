load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(sub, :AtPosition = n) removes the occurrence of sub that starts at the
# given codepoint position (multibyte-safe). Archive block #67.

Scenario("Removing a substring at a given position")
	Given('"ring ♥♥♥ruby php"')
	o1 = new stzString("ring ♥♥♥ruby php")
	o1.RemoveXT("♥♥♥", :AtPosition = 6)
	Then("the hearts at position 6 are removed", o1.Content(), "ring ruby php")
EndScenario()

Summary()
