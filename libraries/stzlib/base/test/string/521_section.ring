load "../../stzBase.ring"
load "../_narrated.ring"

# Section with the :From / :To named spelling. Archive block #521.

Scenario("A named section")
	Then("chars 1..6", Q("NEXTAV TUNISIA").Section(:From = 1, :To = 6), "NEXTAV")
EndScenario()

Summary()
