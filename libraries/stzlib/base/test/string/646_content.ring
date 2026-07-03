load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceNextNthOccurrence: named params in any order.
# Archive block #646.

Scenario("Replacing forward")
	o1 = new stzString( "----@@--@@-------@@----@@---")
	o1.ReplaceNextNthOccurrence(2, :Of = "@@", :StartingAt = 12, :With = "##")
	Then("the 2nd @@ after 12 became ##",
		o1.Content(), "----@@--@@-------@@----##---")
EndScenario()

Summary()
