load "../../stzBase.ring"
load "../_narrated.ring"

# The CONTENT-building half of the boxed-greeting demo: uppercase a substring,
# then wrap a name with hearts. Archive block #102. (The BoxedRound() rendering
# itself is part of the box-rendering defect cluster -- see _AUDIT_DEFECTS.md and
# blocks 99-101 -- so only the content transformation is asserted here.)

Scenario("Building a decorated greeting")
	Given('"Thank you Irwin Rodriguez!"')
	o1 = new stzString("Thank you Irwin Rodriguez!")
	o1.UppercaseSubString("Irwin")
	o1.AddXT( 2Hearts(), :Around = "IRWIN" )
	Then("Irwin is uppercased and hearted", o1.Content(), "Thank you ♥♥IRWIN♥♥ Rodriguez!")
EndScenario()

Summary()
