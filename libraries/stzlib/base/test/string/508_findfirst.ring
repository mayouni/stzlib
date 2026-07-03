load "../../stzBase.ring"
load "../_narrated.ring"

# FindFirst / FindFirstST / FindLast / FindNth -- single-position finds.
# Archive block #508.

Scenario("Single-position finds")
	o1 = new stzString("ab_cd_ef_gh")
	Then("the first underscore", o1.FindFirst("_"), 3)
	Then("a missing star from 4", o1.FindFirstST("*", :StartingAt = 4), 0)
	Then("the underscore from 3", o1.FindFirstST("_", :StartingAt = 3), 3)
	Then("the last underscore", o1.FindLast("_"), 9)
	Then("no last star", o1.FindLast("*"), 0)
	Then("the 2nd underscore", o1.FindNth(2, "_"), 6)
EndScenario()

Summary()
