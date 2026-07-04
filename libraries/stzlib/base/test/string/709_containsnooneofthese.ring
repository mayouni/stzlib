load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsNoOneOfThese. Archive block #709.

Scenario("None of these, then one of these")
	o1 = new stzString("abcdef")
	Then("none present",
		o1.ContainsNoOneOfThese([ "xy", "xyz", "mwb" ]), TRUE)
	Then("de spoils it",
		o1.ContainsNoOneOfThese([ "xy", "xyz", "de", "mwb" ]), FALSE)
EndScenario()

Summary()
