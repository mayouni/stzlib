load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveRepeatedLeading/TrailingChars and the combined form.
# Archive block #770.

Scenario("Stripping both runs")
	o1 = new stzString("eeeTuniseee")
	o1.RemoveRepeatedLeadingChars()
	o1.RemoveRepeatedTrailingChars()
	Then("runs gone", o1.Content(), "Tunis")
	o2 = new stzString("eeeTuniseee")
	o2.RemoveLeadingAndTrailingChars()
	Then("same in one call", o2.Content(), "Tunis")
EndScenario()

Summary()
