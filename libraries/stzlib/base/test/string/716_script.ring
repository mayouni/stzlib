load "../../stzBase.ring"
load "../_narrated.ring"

# TQ(...).Script() -- the dominant script of a text. Archive block #716.

Scenario("Two scripts, two answers")
	Then("arabic", TQ("عربي").Script(), "arabic")
	Then("latin", TQ("ring").Script(), "latin")
EndScenario()

Summary()
