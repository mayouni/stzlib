load "../../stzBase.ring"
load "../_narrated.ring"

# FindZZ -> the [start,end] sections of a substring; ReplaceInSection replaces
# within one section. Verified against archive block #3.

Scenario("FindZZ + ReplaceInSection (single section)")
	Given('"Softanza Programming by Heart"')
	Then("FindZZ locates the section of Programming",
		@@( Q("Softanza Programming by Heart").FindZZ("Programming") ), @@([ [ 10, 20 ] ]))
	Then("ReplaceInSection m->M inside [10,20]", ReplacedInSec(), "Softanza PrograMMing by Heart")
EndScenario()

Summary()

func ReplacedInSec
	o = new stzString("Softanza Programming by Heart")
	o.ReplaceInSection("m", "M", 10, 20)
	return o.Content()
