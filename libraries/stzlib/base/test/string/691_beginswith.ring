load "../../stzBase.ring"
load "../_narrated.ring"

# BeginsWith / EndsWith / IsBoundedBy / TheseBoundsRemoved.
# Archive block #691.

Scenario("Peeling one layer of braces")
	o1 = new stzString("{{{ Scope of Life }}}")
	Then("begins with {", o1.BeginsWith("{"), TRUE)
	Then("ends with }", o1.EndsWith("}"), TRUE)
	Then("bounded by the pair", o1.IsBoundedBy([ "{", "}" ]), TRUE)
	Then("one layer removed",
		o1.TheseBoundsRemoved("{", "}"), "{{ Scope of Life }}")
EndScenario()

Summary()
