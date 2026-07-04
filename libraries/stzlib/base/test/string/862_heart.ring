load "../../stzBase.ring"
load "../_narrated.ring"

# The little glyph helpers. Archive block #862.

Scenario("Eight glyphs by name")
	Then("heart", Heart(), "♥")
	Then("smile", Smile(), "😆")
	Then("handshake", Handshake(), "🤝")
	Then("sun", Sun(), "🌞")
	Then("star", Star(), "★")
	Then("check mark", CheckMark(), "✓")
	Then("dot", Dot(), "•")
	Then("flower", Flower(), "✤")
EndScenario()

Summary()
