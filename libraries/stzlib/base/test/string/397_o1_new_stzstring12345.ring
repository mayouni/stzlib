load "../../stzBase.ring"
load "../_narrated.ring"

# Section's symbolic params: :First / :Last resolve to the edges, and :@
# MIRRORS the other param (per the original SectionCS). Negative indexes
# stay OUT OF Section's strict contract -- the archive's Section(2, -2)
# --> "234" never matched the original impl (which raises "Indexes out of
# range!"); the lenient negatives-from-end form is SectionXT.
# Archive block #397.

Scenario("Symbolic section positions")
	Given('"12345"')
	o1 = new stzString("12345")
	Then("a plain section", o1.Section(2, 4), "234")
	Then("negatives belong to the XT form", o1.SectionXT(2, -2), "234")
	Then(":First to :Last spans it all", o1.Section(:First, :Last), "12345")
	Then(":@ mirrors the left param", o1.Section(3, :@), "3")
	Then(":@ mirrors the right param", o1.Section(:@, 3), "3")
EndScenario()

Summary()
