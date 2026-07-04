load "../../stzBase.ring"
load "../_narrated.ring"

# IsMadeOfSome with the char-set helpers. Archive block #848.

Scenario("Octal and binary digit sets")
	Then("all octal digits qualify",
		Q("01234567").IsMadeOfSome( OctalChars() ), TRUE)
	Then("a binary string uses both bits",
		Q("001100101").IsMadeOf( BinaryChars() ), TRUE)
EndScenario()

Summary()
