load "../../stzBase.ring"
load "../_narrated.ring"

# FindPrevious / FindNthPrevious on a multibyte string.
# Archive block #988.

Scenario("Hearts behind the cursor")
	o1 = new stzString("12♥4♥67")
	Then("previous from 5", o1.FindPrevious("♥", :StartingAt = 5), 3)
	Then("2nd previous from 6",
		o1.FindNthPrevious(2, "♥", :StartingAt = 6), 3)
EndScenario()

Summary()
