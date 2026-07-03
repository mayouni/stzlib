load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveFirstChar / FirstCharRemoved. Archive block #683.

Scenario("Dropping the first char")
	o1 = new stzString("1BATISTA")
	o1.RemoveFirstChar()
	Then("mutated in place", o1.Content(), "BATISTA")
	Then("or functionally",
		StzStringQ("1BATISTA").FirstCharRemoved(), "BATISTA")
EndScenario()

Summary()
