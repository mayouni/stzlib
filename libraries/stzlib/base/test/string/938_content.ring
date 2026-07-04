load "../../stzBase.ring"
load "../_narrated.ring"

# BoxifyCharsXT options: mixed :Corners (clockwise), :Numbered rail,
# and :Rounded = FALSE overriding the corners. Archive block #938.

Scenario("Numbered cells with mixed corners")
	o1 = new stzString("SOFTANZA~RING")
	o1.BoxifyCharsXT([
		:Rounded = TRUE,
		:Corners = [ :Round, :Rect, :Round, :Rect ],
		:Numbered = TRUE
	])
	Then("cells, corners and numbers",
		o1.Content(),
		"╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐" + NL +
		"│ S │ O │ F │ T │ A │ N │ Z │ A │ ~ │ R │ I │ N │ G │" + NL +
		"└───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯" + NL +
		"  1   2   3   4   5   6   7   8   9   10  11  12  13")
EndScenario()

Scenario(":Rounded = FALSE wins over :Corners")
	o2 = new stzString("SOFTANZA~RING")
	o2.BoxifyCharsXT([
		:Rounded = FALSE,
		:Corners = [ :Round, :Rect, :Round, :Rect ],
		:Numbered = TRUE
	])
	Then("all corners rectangular",
		o2.Content(),
		"┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐" + NL +
		"│ S │ O │ F │ T │ A │ N │ Z │ A │ ~ │ R │ I │ N │ G │" + NL +
		"└───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘" + NL +
		"  1   2   3   4   5   6   7   8   9   10  11  12  13")
EndScenario()

Summary()
