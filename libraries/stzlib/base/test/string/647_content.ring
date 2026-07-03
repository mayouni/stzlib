load "../../stzBase.ring"
load "../_narrated.ring"

# ... and its backward twin. Archive block #647.

Scenario("Replacing backward")
	o1 = new stzString( "----@@--@@-------@@----@@---")
	o1.ReplacePreviousNthOccurrence(2, :Of = "@@", :StartingAt = 22, :With = "##")
	Then("the 2nd @@ before 22 became ##",
		o1.Content(), "----@@--##-------@@----@@---")
EndScenario()

Summary()
