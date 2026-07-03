load "../../stzBase.ring"
load "../_narrated.ring"

# ... and descending. Archive block #620.

Scenario("Descending or not")
	Then("3-2-1 descends",
		Q("My name is #3, my age is #2, and my job is #1.").MarquersAreSortedIndescending(), TRUE)
	Then("2-1-3 does not",
		Q("My name is #2, my age is #1, and my job is #3.").MarquersAreSortedInDescending(), FALSE)
EndScenario()

Summary()
