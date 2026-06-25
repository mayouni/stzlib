load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisCharFromStartXT / RemoveThisCharFromEndXT -- strip every leading (or
# trailing) run of the given char; a char that isn't there is a no-op. Mutating
# sequence. Archive block #20.

Scenario("Stripping leading and trailing runs of a char")
	Given('"---ring---"')
	o1 = new stzString("---ring---")
	o1.RemoveThisCharFromStartXT("*")
	Then("'*' from start (absent) is a no-op", o1.Content(), "---ring---")
	o1.RemoveThisCharFromStartXT("-")
	Then("'-' from start strips the leading dashes", o1.Content(), "ring---")
	o1.RemoveThisCharFromEndXT("*")
	Then("'*' from end (absent) is a no-op", o1.Content(), "ring---")
	o1.RemoveThisCharFromEndXT("-")
	Then("'-' from end strips the trailing dashes", o1.Content(), "ring")
EndScenario()

Summary()
