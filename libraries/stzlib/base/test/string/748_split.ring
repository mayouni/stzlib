load "../../stzBase.ring"
load "../_narrated.ring"

# SplitQ chains into the parts list; the long natural-coding name does
# the same in one call. Archive block #748.

Scenario("The third field of a record")
	o1 = new stzString("abc;123;gafsa;ykj")
	Then("via SplitQ", o1.SplitQ(";").NthItem(3), "gafsa")
	Then("via the long natural name",
		o1.NthSubstringAfterSplittingStringUsing(3, ";"), "gafsa")
EndScenario()

Summary()
