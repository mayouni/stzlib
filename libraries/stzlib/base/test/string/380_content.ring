load "../../stzBase.ring"
load "../_narrated.ring"

# AddXT(what, :Before = anchor) inserts right before the anchor.
# Archive block #380.

Scenario("Adding before an anchor")
	Given('"Ring programming guage."')
	o1 = new stzString("Ring programming guage.")
	o1.AddXT("lan", :Before = "guage")
	Then("the missing syllable lands", o1.Content(), "Ring programming language.")
EndScenario()

Summary()
