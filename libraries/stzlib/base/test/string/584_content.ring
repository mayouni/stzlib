load "../../stzBase.ring"
load "../_narrated.ring"

# The CS dial works with the :Last symbol too. Archive block #584.

Scenario("Removing the last a, case aside")
	o1 = new stzString("**A1****A2***A3")
	o1.RemoveNthOccurrenceCS(:Last, "a", :CaseSensitive = FALSE)
	Then("the third A is gone", o1.Content(), "**A1****A2***3")
EndScenario()

Summary()
