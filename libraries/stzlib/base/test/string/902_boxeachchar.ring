load "../../stzBase.ring"
load "../_narrated.ring"

# BoxEachChar mutates the string into its per-char cell strip.
# Archive block #902.

Scenario("RING in cells, in place")
	o1 = new stzString("RING")
	Then("the Q form returns the strip",
		o1.BoxEachCharQ().Content(), "┌───┬───┬───┬───┐" + NL + "│ R │ I │ N │ G │" + NL + "└───┴───┴───┴───┘")
	Then("... and the object holds it",
		o1.Content(), "┌───┬───┬───┬───┐" + NL + "│ R │ I │ N │ G │" + NL + "└───┴───┴───┴───┘")
EndScenario()

Summary()
