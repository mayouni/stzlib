load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisCharFromLeftXT(c) -- the Left-spelled alias of RemoveThisCharFromStartXT:
# strip the whole leading run of char c, no-op if c is absent. Mutating. Archive
# block #22.

Scenario("Stripping the leading run of a char (Left alias)")
	Given('"---ring"')
	o1 = new stzString("---ring")
	o1.RemoveThisCharFromLeftXT("*")
	Then("'*' from left (absent) is a no-op", o1.Content(), "---ring")
	o1.RemoveThisCharFromLeftXT("-")
	Then("'-' from left strips the leading dashes", o1.Content(), "ring")
EndScenario()

Summary()
