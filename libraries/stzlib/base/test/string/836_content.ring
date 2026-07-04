load "../../stzBase.ring"
load "../_narrated.ring"

# The plain InsertSubStrings form: default parens-and-commas format.
# Archive block #836.

Scenario("Three versions, default dress")
	o1 = new stzString("All our software versions must be updated!")
	o1.InsertSubStrings( o1.PositionAfter("versions"), [ "V1", "V2", "V3" ])
	Then("parenthesized with padding spaces",
		o1.Content(),
		"All our software versions (V1, V2, V3)  must be updated!")
EndScenario()

Summary()
