load "../../stzBase.ring"
load "../_narrated.ring"

# LeadingChar reads the run's char; RemoveThisLeadingChar peels the
# run when it matches. Archive block #677.

Scenario("Reading then removing the leading zeros")
	o1 = new stzString("000122.12")
	Then("the leading char", o1.LeadingChar(), "0")
	o1.RemoveThisLeadingChar("0")
	Then("the run is gone", o1.Content(), "122.12")
EndScenario()

Summary()
