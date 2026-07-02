load "../../stzBase.ring"
load "../_narrated.ring"

# A lone space is not a number in a string. Archive block #461.

Scenario("Space is not a number")
	Then("IsNumberInString on a space", Q(" ").IsNumberInString(), FALSE)
EndScenario()

Summary()
