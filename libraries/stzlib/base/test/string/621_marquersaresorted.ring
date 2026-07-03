load "../../stzBase.ring"
load "../_narrated.ring"

# MarquersAreSorted + the sorting order. Archive block #621.

Scenario("Ascending marquers")
	o1 = new stzString("My name is #1, my age is #2, and my job is #3.")
	Then("they are sorted", o1.MarquersAreSorted(), TRUE)
	Then("... ascending", o1.MarquersSortingOrder(), :Ascending)
EndScenario()

Summary()
