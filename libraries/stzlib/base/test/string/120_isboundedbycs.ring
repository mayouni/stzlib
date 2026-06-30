load "../../stzBase.ring"
load "../_narrated.ring"

# IsBoundedByCS accepts a single-string bound (widened to [c, c]); "aa***aa**aa***aa"
# is bounded by "aa" on both ends. Archive block #120.

Scenario("A string bounded by a single repeated marker")
	Given('"aa***aa**aa***aa"')
	o1 = new stzString("aa***aa**aa***aa")
	Then("it IS bounded by 'aa'", o1.IsBoundedByCS("aa", TRUE), TRUE)
EndScenario()

Summary()
