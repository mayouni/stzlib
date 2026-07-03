load "../../stzBase.ring"
load "../_narrated.ring"

# TheseBoundsRemoved: the passive strip of a given bound pair.
# Archive block #580.

Scenario("Unwrapping Go!")
	o1 = new stzString("<<Go!>>")
	Then("the bounds fall away", o1.TheseBoundsRemoved("<<", ">>"), "Go!")
EndScenario()

Summary()
