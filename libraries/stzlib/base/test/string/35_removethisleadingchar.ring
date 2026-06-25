load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisLeadingChar(c) -- peel the whole leading run ONLY when it is made of
# char c; a non-matching c is a no-op. Archive block #35.

Scenario("Conditionally peeling the leading run")
	Given('"---Ring"')
	o1 = new stzString("---Ring")
	o1.RemoveThisLeadingChar("*")
	Then("'*' (no match) leaves the string untouched", o1.Content(), "---Ring")
	o1.RemoveThisLeadingChar("-")
	Then("'-' peels the whole leading run", o1.Content(), "Ring")
EndScenario()

Summary()
