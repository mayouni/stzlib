load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceNthOccurrence, with an emoji along for the ride.
# Archive block #824.

Scenario("Only the second Dan")
	o1 = new stzString("Hi Dan! You are Dan, but your work is never done! 😉")
	o1.ReplaceNthOccurrence(2, "Dan", "hardworker")
	Then("the first Dan stays",
		o1.Content(),
		"Hi Dan! You are hardworker, but your work is never done! 😉")
EndScenario()

Summary()
