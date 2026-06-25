load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisCharFromRightXT(c) -- the Right-spelled alias of RemoveThisCharFromEndXT:
# strip the whole trailing run of char c, no-op if c is absent. Mutating. Archive
# block #23.

Scenario("Stripping the trailing run of a char (Right alias)")
	Given('"ring---"')
	o1 = new stzString("ring---")
	o1.RemoveThisCharFromRightXT("*")
	Then("'*' from right (absent) is a no-op", o1.Content(), "ring---")
	o1.RemoveThisCharFromRightXT("-")
	Then("'-' from right strips the trailing dashes", o1.Content(), "ring")
EndScenario()

Summary()
