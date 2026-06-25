load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisCharFromRightXT(c) in the wild -- trimming the trailing zeros off a
# decimal literal. Strips the whole trailing run of c. Archive block #26.

Scenario("Trimming trailing zeros from a decimal")
	Given('"12.58000"')
	o1 = new stzString("12.58000")
	o1.RemoveThisCharFromRightXT("0")
	Then("the trailing zeros are gone", o1.Content(), "12.58")
EndScenario()

Summary()
