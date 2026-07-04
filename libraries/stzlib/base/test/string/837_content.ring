load "../../stzBase.ring"
load "../_narrated.ring"

# InsertSubStringsXT with just one option: everything else stays off.
# Archive block #837.

Scenario("Plus-separated versions")
	o1 = new stzString("All our software versions must be updated!")
	o1.InsertSubStringsXT(
		o1.PositionAfter("versions"),
		[ " V1", "V2", "V3" ],
		[ :MainSeparator = "+" ]
	)
	Then("bare join",
		o1.Content(),
		"All our software versions V1+V2+V3 must be updated!")
EndScenario()

Summary()
