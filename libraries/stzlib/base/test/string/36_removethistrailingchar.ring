load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveThisTrailingChar(c) -- peel the whole trailing run ONLY when it is made
# of char c; a non-matching c is a no-op. Mirror of block #35. Archive block #36.

Scenario("Conditionally peeling the trailing run")
	Given('"Ring---"')
	o1 = new stzString("Ring---")
	o1.RemoveThisTrailingChar("*")
	Then("'*' (no match) leaves the string untouched", o1.Content(), "Ring---")
	o1.RemoveThisTrailingChar("-")
	Then("'-' peels the whole trailing run", o1.Content(), "Ring")
EndScenario()

Summary()
