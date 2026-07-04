load "../../stzBase.ring"
load "../_narrated.ring"

# The string twin of 941: no trailing space after the final char.
# Archive block #944.

Scenario("Spaces after the even positions")
	o1 = new stzString("SOFTANZA")
	o1.InsertAfterPositions([ 2, 4, 6, 8 ], " ")
	Then("pairs, no trailing space", o1.Content(), "SO FT AN ZA")
EndScenario()

Summary()
