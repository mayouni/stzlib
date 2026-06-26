load "../../stzBase.ring"
load "../_narrated.ring"

# Negative string indexing: [-2] is the second char from the end. Archive #130.

Scenario("Indexing a string from the end")
	Then("[-2] of 'ABCDE' is 'D'", Q("ABCDE")[-2], "D")
EndScenario()

Summary()
