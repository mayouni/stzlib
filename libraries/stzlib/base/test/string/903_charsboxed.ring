load "../../stzBase.ring"
load "../_narrated.ring"

# CharsBoxed is the non-mutating reading. Archive block #903.

Scenario("RING in cells, functional")
	Then("the strip",
		Q("RING").CharsBoxed(), "┌───┬───┬───┬───┐" + NL + "│ R │ I │ N │ G │" + NL + "└───┴───┴───┴───┘")
EndScenario()

Summary()
