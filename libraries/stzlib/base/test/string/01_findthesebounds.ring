load "../../stzBase.ring"
load "../_narrated.ring"

# FindTheseBounds("[","]") -> [open,close] positions of the outer bracket pair;
# RemoveTheseBounds drops the bound chars (here only the matched [ and ] at the
# ends). Verified against archive block #1.

Scenario("FindTheseBounds / RemoveTheseBounds")
	Given('the string [ @$2{"a";1;[1]}U ]')
	Then("FindTheseBounds reports the outer [ ] positions",
		@@( Q('[ @$2{"a";1;[1]}U ]').FindTheseBounds("[", "]") ), @@([ 1, 15 ]))
	Then("RemoveTheseBounds drops the outer bounds", RemovedBounds(), ' @$2{"a";1;[1}U ]')
EndScenario()

Summary()

func RemovedBounds
	o = new stzString('[ @$2{"a";1;[1]}U ]')
	o.RemoveTheseBounds("[", "]")
	return o.Content()
