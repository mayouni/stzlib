load "../../stzBase.ring"
load "../_narrated.ring"

# IsMadeOfSome with HexChars. Archive block #850.

Scenario("A hex fragment")
	Then("all chars are hex digits",
		Q("4E992").IsMadeOfSome( HexChars() ), TRUE)
EndScenario()

Summary()
