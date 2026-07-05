load "../../stzBase.ring"
load "../_narrated.ring"

# FindNext past the end finds nothing. Archive block #987.

Scenario("Scanning from beyond the string")
	o1 = new stzString("123456789")
	Then("nothing at or after 10",
		o1.FindNext("1", :startingAt = 10), 0)
EndScenario()

Summary()
