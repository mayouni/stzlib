load "../../stzBase.ring"
load "../_narrated.ring"

# Shrink(:ToPosition = n) -- cut the string down to its first n chars. Archive #146.

Scenario("Shrinking a string to a position")
	o1 = new stzString("ABCDE")
	o1.Shrink( :ToPosition = 3 )
	Then("'ABCDE' shrunk to position 3", o1.Content(), "ABC")
EndScenario()

Summary()
