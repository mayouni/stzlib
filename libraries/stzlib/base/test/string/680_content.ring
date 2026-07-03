load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveNLastChars (mutating) / LastNCharsRemoved (functional).
# Archive block #680.

Scenario("Dropping the numeric tail")
	o1 = new stzString("BATISTA123")
	o1.RemoveNLastChars(3)
	Then("mutated in place", o1.Content(), "BATISTA")
	Then("or functionally",
		StzStringQ("BATISTA123").LastNCharsRemoved(3), "BATISTA")
EndScenario()

Summary()
