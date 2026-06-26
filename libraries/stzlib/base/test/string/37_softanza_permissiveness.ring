load "../../stzBase.ring"
load "../_narrated.ring"

# Softanza permissiveness: RemoveFirstChar() drops the first char regardless of
# case, and RemoveFirstCharCS(bCaseSensitive) ACCEPTS a case-sensitivity flag
# even though it is meaningless here (the first char is the first char) -- the
# flag is simply ignored. Archive block #37.

Scenario("A case-sensitivity flag that is permissively ignored")
	Given('"rRing"')
	o1 = new stzString("rRing")
	o1.RemoveFirstChar()
	Then("RemoveFirstChar() drops the leading 'r'", o1.Content(), "Ring")

	Given('a fresh "rRing"')
	o2 = new stzString("rRing")
	o2.RemoveFirstCharCS(TRUE)
	Then("RemoveFirstCharCS(TRUE) ignores the flag, same result", o2.Content(), "Ring")
EndScenario()

Summary()
