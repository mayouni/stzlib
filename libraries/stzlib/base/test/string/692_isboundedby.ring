load "../../stzBase.ring"
load "../_narrated.ring"

# IsBoundedBy with a NULL side: only the given bound is required.
# Archive block #692.

Scenario("Bounded on both sides, or just one")
	o1 = new stzString('"name"')
	Then("quoted on both sides", o1.IsBoundedBy([ '"', '"' ]), TRUE)
	o2 = new stzString(":name")
	Then("a leading colon is enough",
		o2.IsBoundedBy([ ":", NULL ]), TRUE)
EndScenario()

Summary()
