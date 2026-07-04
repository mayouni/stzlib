load "../../stzBase.ring"
load "../_narrated.ring"

# The four StringAlignXT directions -- including :Justified, which
# spreads the chars with front-loaded gaps. Archive block #812.

Scenario("SOFTANZA four ways in 30 columns")
	Then("left",
		StringAlignXT("SOFTANZA", 30, ".", :Left),
		"SOFTANZA......................")
	Then("right",
		StringAlignXT("SOFTANZA", 30, ".", :Right),
		"......................SOFTANZA")
	Then("center",
		StringAlignXT("SOFTANZA", 30, ".", :Center),
		"...........SOFTANZA...........")
	Then("justified",
		StringAlignXT("SOFTANZA", 30, ".", :Justified),
		"S....O...F...T...A...N...Z...A")
EndScenario()

Summary()
