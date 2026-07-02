load "../../stzBase.ring"
load "../_narrated.ring"

# IsCircledNumber on the circled digit 1 (U+2460). The archive source
# had the char double-encoded (mojibake); rebuilt with the real glyph.
# Archive block #479.

Scenario("A circled digit")
	Then("① is a circled number", QQ("①").IsCircledNumber(), TRUE)
EndScenario()

Summary()
