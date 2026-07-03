load "../../stzBase.ring"
load "../_narrated.ring"

# Descending marquers are sorted too. Archive block #622.

Scenario("Descending marquers")
	o1 = new stzString("My name is #3, my age is #2, and my job is #1.")
	Then("they are sorted", o1.MarquersAreSorted(), TRUE)
	Then("... descending", o1.MarquersSortingOrder(), :Descending)
EndScenario()

Summary()
