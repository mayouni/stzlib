load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceAllExcept([...], :With = new) replaces every run that is NOT in the kept
# list with `new` (one replacement per run). Archive block #79.

Scenario("Replacing everything except the listed runs")
	Given('"--Ring--__Softanza__"')
	o1 = new stzString("--Ring--__Softanza__")
	o1.ReplaceAllExcept([ "Ring", "&", "Softanza" ], :With = AHeart())
	Then("each non-kept run becomes a heart", o1.Content(), "♥Ring♥Softanza♥")
EndScenario()

Summary()
