load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveNFirstChars / FirstNCharsRemoved. Archive block #682.

Scenario("Dropping the numeric head")
	o1 = new stzString("123BATISTA")
	o1.RemoveNFirstChars(3)
	Then("mutated in place", o1.Content(), "BATISTA")
	Then("or functionally",
		StzStringQ("123BATISTA").FirstNCharsRemoved(3), "BATISTA")
EndScenario()

Summary()
