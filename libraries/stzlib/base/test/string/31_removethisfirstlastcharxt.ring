load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisFirstCharXT(c) / RemoveThisLastCharXT(c) -- peel the leading /
# trailing run ONLY when the end char equals c; a non-matching c is a no-op.
# Archive block #31.

Scenario("Conditionally peeling each end")
	Given('"---Ring---"')
	o1 = new stzString("---Ring---")
	o1.RemoveThisFirstCharXT("*")
	Then("'*' at the start (no match) is a no-op", o1.Content(), "---Ring---")
	o1.RemoveThisFirstCharXT("-")
	Then("'-' at the start peels the leading run", o1.Content(), "Ring---")
	o1.RemoveThisLastCharXT("*")
	Then("'*' at the end (no match) is a no-op", o1.Content(), "Ring---")
	o1.RemoveThisLastCharXT("-")
	Then("'-' at the end peels the trailing run", o1.Content(), "Ring")
EndScenario()

Summary()
