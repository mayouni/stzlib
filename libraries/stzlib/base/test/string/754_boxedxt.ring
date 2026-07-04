load "../../stzBase.ring"
load "../_narrated.ring"

# BoxedXT: whole-string box vs the :EachChar cells. Archive block #754.

Scenario("SOFTANZA, one box or eight")
	Then("one box",
		StzStringQ("SOFTANZA").BoxedXT([]),
		"┌──────────┐" + NL +
		"│ SOFTANZA │" + NL +
		"└──────────┘")
	Then("eight cells",
		StzStringQ("SOFTANZA").BoxedXT([ :EachChar = TRUE ]),
		"┌───┬───┬───┬───┬───┬───┬───┬───┐" + NL +
		"│ S │ O │ F │ T │ A │ N │ Z │ A │" + NL +
		"└───┴───┴───┴───┴───┴───┴───┴───┘")
EndScenario()

Summary()
