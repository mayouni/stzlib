load "../../stzBase.ring"
load "../_narrated.ring"

# ContainsXT restricts the search to a section or sections.
# Archive block #103.

Scenario("Hearts within sections")
	o1 = new stzString("123♥♥678♥♥1234♥♥789")
	Then("a heart in [3, 10]",
		o1.ContainsXT( "♥", :InSection = [ 3, 10 ] ), TRUE)
	Then("a heart in any of the sections",
		o1.ContainsXT( "♥", :InSections = [ [ 3, 10 ], [ 8, 12 ], [ 14, 19 ] ] ), TRUE)
EndScenario()

Summary()
