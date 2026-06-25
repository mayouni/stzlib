load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisCharFromEndXT -- strip the trailing run of a char (no-op if absent).
# Archive block #21.

Scenario("Stripping the trailing run of a char")
	Given('"ring---"')
	o1 = new stzString("ring---")
	o1.RemoveThisCharFromEndXT("*")
	Then("'*' from end (absent) is a no-op", o1.Content(), "ring---")
	o1.RemoveThisCharFromEndXT("-")
	Then("'-' from end strips the trailing dashes", o1.Content(), "ring")
EndScenario()

Summary()
