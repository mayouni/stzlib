load "../../stzBase.ring"
load "../_narrated.ring"

# FindNthOccurrenceCS. Archive block #695.

Scenario("The third Mio")
	o1 = new stzString("---Mio---Mio---Mio---Mio---")
	Then("sits at 16", o1.FindNthOccurrenceCS(3, "Mio", TRUE), 16)
EndScenario()

Summary()
