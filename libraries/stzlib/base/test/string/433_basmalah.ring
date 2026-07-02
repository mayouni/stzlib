load "../../stzBase.ring"
load "../_narrated.ring"

# The glyph shorthands: Basmalah, Heart, and the numbered plural forms.
# Archive block #433.

Scenario("Glyph shorthands")
	Then("the Basmalah ligature", Basmalah(), "﷽")
	Then("a heart", Heart(), "♥")
	Then("three hearts", 3Hearts(), "♥♥♥")
	Then("five stars", 5Stars(), "★★★★★")
EndScenario()

Summary()
