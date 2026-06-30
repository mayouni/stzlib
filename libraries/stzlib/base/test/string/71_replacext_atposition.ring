load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceXT(sub, :AtPosition = n, :By = new) replaces the occurrence of sub that
# starts at codepoint position n. Archive block #71.

Scenario("Replacing a substring at a given position")
	Given('"ruby ring php"')
	o1 = new stzString("ruby ring php")
	o1.ReplaceXT("ring", :AtPosition = 6, :By = "♥♥♥")
	Then("the 'ring' at position 6 becomes hearts", o1.Content(), "ruby ♥♥♥ php")
EndScenario()

Summary()
