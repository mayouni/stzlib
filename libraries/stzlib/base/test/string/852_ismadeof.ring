load "../../stzBase.ring"
load "../_narrated.ring"

# IsMadeOf tolerates repeated tokens. Archive block #852.

Scenario("maan from its letters")
	Then("made of m, a, a, n",
		Q("maan").IsMadeOf([ "m", "a", "a", "n" ]), TRUE)
EndScenario()

Summary()
