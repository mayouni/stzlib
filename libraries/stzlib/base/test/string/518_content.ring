load "../../stzBase.ring"
load "../_narrated.ring"

# Swapping two SUBSTRINGS by value. Archive block #518.

Scenario("Putting ONE before TWO")
	o1 = new stzString("TWO, ONE, THREE!")
	o1.Swap("TWO", :And = "ONE")
	Then("the words traded places", o1.Content(), "ONE, TWO, THREE!")
EndScenario()

Summary()
