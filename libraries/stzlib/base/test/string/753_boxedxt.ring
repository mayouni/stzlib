load "../../stzBase.ring"
load "../_narrated.ring"

# BoxedXT with :Width and the four :TextAdjustedTo modes. (The archive
# listed the right outputs under the wrong labels -- a copy-scramble;
# each mode below asserts its own natural output.) Archive block #753.

Scenario("PARIS in a 20-wide box, four ways")
	cTop = "╭────────────────────╮"
	cBot = "╰────────────────────╯"
	Then("centered",
		StzStringQ("PARIS").BoxedXT([ :AllCorners = :Round, :Width = 20, :TextAdjustedTo = :Center ]),
		cTop + NL + "│       PARIS        │" + NL + cBot)
	Then("left",
		StzStringQ("PARIS").BoxedXT([ :AllCorners = :Round, :Width = 20, :TextAdjustedTo = :Left ]),
		cTop + NL + "│ PARIS              │" + NL + cBot)
	Then("right",
		StzStringQ("PARIS").BoxedXT([ :AllCorners = :Round, :Width = 20, :TextAdjustedTo = :Right ]),
		cTop + NL + "│              PARIS │" + NL + cBot)
	Then("justified",
		StzStringQ("PARIS").BoxedXT([ :AllCorners = :Round, :Width = 20, :TextAdjustedTo = :Justified ]),
		cTop + NL + "│ P    A   R   I   S │" + NL + cBot)
EndScenario()

Summary()
