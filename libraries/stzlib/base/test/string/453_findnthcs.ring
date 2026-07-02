load "../../stzBase.ring"
load "../_narrated.ring"

# stzList.FindNthCS: the nth occurrence, case-insensitively here.
# Archive block #453.

Scenario("Third A in a list")
	o1 = new stzList([ "A", "A", "A", "B", "B", "C" ])
	Then("the 3rd A sits at 3", o1.FindNthCS(3, "A", FALSE), 3)
EndScenario()

Summary()
