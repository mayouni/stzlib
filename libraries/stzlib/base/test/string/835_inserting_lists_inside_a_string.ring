load "../../stzBase.ring"
load "../_narrated.ring"

# InsertSubstringsXT: insert a formatted list at a position, with
# opening/closing chars, separators, an "and" before the last item,
# and a leading space. Archive block #835.

Scenario("Announcing five versions")
	o1 = new stzString("All our software versions must be updated!")
	nPosition = o1.PositionAfter("versions")
	o1.InsertSubstringsXT(
		nPosition,
		[ "V1", "V2", "V3", "V4", "V5" ],
		[
			:InsertBeforeOrAfter = :Before,
			:OpeningChar = "{ ",
			:ClosingChar = " }",
			:MainSeparator = ",",
			:AddSpaceAfterSeparator = TRUE,
			:LastSeparator = "and",
			:AddLastToMainSeparator = TRUE,
			:SpaceOption = :AddLeadingSpace
		]
	)
	Then("the list sits in the sentence",
		o1.Content(),
		"All our software versions { V1, V2, V3, V4, and V5 } must be updated!")
EndScenario()

Summary()
