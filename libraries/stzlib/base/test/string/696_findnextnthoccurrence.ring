load "../../stzBase.ring"
load "../_narrated.ring"

# FindNextNthOccurrence: the nth occurrence at or after a position.
# Archive block #696.

Scenario("Walking the Mios forward")
	o1 = new stzString("---Mio---Mio---Mio---Mio---")
	Then("1st from the start",
		o1.FindNextNthOccurrence(1, "Mio", :StartingAt = 1), 4)
	Then("2nd from 7",
		o1.FindNextNthOccurrence(2, "Mio", :StartingAt = 7), 16)
	Then("1st from 20",
		o1.FindNextNthOccurrence(1, "Mio", :StartingAt = 20), 22)
EndScenario()

Summary()
