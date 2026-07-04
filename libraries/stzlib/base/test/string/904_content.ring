load "../../stzBase.ring"
load "../_narrated.ring"

# BoxifyChars mutates too. Archive block #904.

Scenario("SOFTANZA in cells")
	o1 = new stzString("SOFTANZA")
	o1.BoxifyChars()
	Then("eight cells",
		o1.Content(), "┌───┬───┬───┬───┬───┬───┬───┬───┐" + NL + "│ S │ O │ F │ T │ A │ N │ Z │ A │" + NL + "└───┴───┴───┴───┴───┴───┴───┴───┘")
EndScenario()

Summary()
