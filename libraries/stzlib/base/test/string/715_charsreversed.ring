load "../../stzBase.ring"
load "../_narrated.ring"

# CharsReversed reverses the ORDER of the chars. (The archive's
# upside-down glyphs came from a retired Qt char-flipping toy, not
# from reversal.) Simplified() squeezes the whitespace.
# Archive block #715.

Scenario("Reversing and simplifying")
	Then("SOFTANZA backwards",
		StzStringQ("SOFTANZA").CharsReversed(), "AZNATFOS")
	Then("whitespace squeezed",
		StzStringQ(" Softanza    Near-natural Programming   ").Simplified(),
		"Softanza Near-natural Programming")
EndScenario()

Summary()
