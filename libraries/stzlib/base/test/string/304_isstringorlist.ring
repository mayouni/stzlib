load "../../stzBase.ring"
load "../_narrated.ring"

# IsStringOrList() -- a type-union check on stz objects. Archive block #304.

Scenario("A string is a string-or-list")
	Then('Q("believe").IsStringOrList()', Q("believe").IsStringOrList(), TRUE)
EndScenario()

Summary()
