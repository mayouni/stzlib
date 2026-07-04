load "../../stzBase.ring"
load "../_narrated.ring"

# AlignedXT with named :Width / :Char / :Direction.
# Archive block #811.

Scenario("Centering with dots")
	Then("eleven dots each side",
		Q("SFOTANZA").AlignedXT( :Width = 30, :Char = ".", :Direction = :Center ),
		"...........SFOTANZA...........")
EndScenario()

Summary()
