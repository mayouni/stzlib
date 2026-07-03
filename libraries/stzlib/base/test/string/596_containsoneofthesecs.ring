load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsOneOfTheseCS with the case dial. Archive block #596.

Scenario("Mama matches, case aside")
	o1 = new stzString("Baba, Mama, and Dada")
	Then("one of the two is there",
		o1.ContainsOneOfTheseCS([ "Mom", "mama" ], :CaseSensitive = FALSE), TRUE)
EndScenario()

Summary()
