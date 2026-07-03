load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveLastChar / LastCharRemoved. Archive block #681.

Scenario("Dropping the last char")
	o1 = new stzString("BATISTA1")
	o1.RemoveLastChar()
	Then("mutated in place", o1.Content(), "BATISTA")
	Then("or functionally",
		StzStringQ("BATISTA1").LastCharRemoved(), "BATISTA")
EndScenario()

Summary()
