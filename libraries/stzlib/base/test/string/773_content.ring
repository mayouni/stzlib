load "../../stzBase.ring"
load "../_narrated.ring"

# ... while the Each* forms replace char BY char. Archive block #773.

Scenario("Starring each run char")
	o1 = new stzString("___VAR---")
	o1.ReplaceEachLeadingChar(:With = "*")
	Then("three leading stars", o1.Content(), "***VAR---")
	o2 = new stzString("___VAR---")
	o2.ReplaceEachTrailingChar(:With = "*")
	Then("three trailing stars", o2.Content(), "___VAR***")
	o3 = new stzString("___VAR---")
	o3.ReplaceEachLeadingAndTrailingChar(:With = "*")
	Then("both ends", o3.Content(), "***VAR***")
EndScenario()

Summary()
