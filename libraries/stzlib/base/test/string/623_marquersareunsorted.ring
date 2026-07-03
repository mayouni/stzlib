load "../../stzBase.ring"
load "../_narrated.ring"

# ... and 1-3-2 is unsorted. Archive block #623.

Scenario("Unsorted marquers")
	o1 = new stzString("My name is #1, my age is #3, and my job is #2.")
	Then("they are unsorted", o1.MarquersAreUnsorted(), TRUE)
	Then("the order says so", o1.MarquersSortingOrder(), :Unsorted)
EndScenario()

Summary()
