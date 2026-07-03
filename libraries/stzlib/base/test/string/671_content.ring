load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisTrailingChar (mutating) and ThisTrailingCharRemoved
# (functional twin). Archive block #671.

Scenario("Peeling the trailing zeros")
	o1 = new stzString("12.4560000")
	o1.RemoveThisTrailingChar("0")
	Then("mutated in place", o1.Content(), "12.456")
	Then("or functionally",
		Q("12.45600").ThisTrailingCharRemoved("0"), "12.456")
EndScenario()

Summary()
