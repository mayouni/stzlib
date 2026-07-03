load "../../stzBase.ring"
load "../_narrated.ring"

# NthToLast(n) = the char at position len - n (the original:
# CharAtPosition(NumberOfChars() - n)). Archive block #522.

Scenario("Third char before the last")
	Then("SOFTANZA's 3rd-to-last is A", Q("SOFTANZA").NthToLast(3), "A")
EndScenario()

Summary()
