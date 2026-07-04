load "../../stzBase.ring"
load "../_narrated.ring"

# BoxifyCharsXT with no options matches the plain form.
# Archive block #905.

Scenario("SOFTANZA in cells, XT spelling")
	o1 = new stzString("SOFTANZA")
	o1.BoxifyCharsXT([])
	Then("same eight cells",
		o1.Content(), "┌───┬───┬───┬───┬───┬───┬───┬───┐" + NL + "│ S │ O │ F │ T │ A │ N │ Z │ A │" + NL + "└───┴───┴───┴───┴───┴───┴───┴───┘")
EndScenario()

Summary()
