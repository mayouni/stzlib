load "../../stzBase.ring"
load "../_narrated.ring"

# The walk quartet is STRICTLY EXCLUSIVE of the start position, in
# both directions (the original scans Section(1, nStart - 1) for the
# previous family). Archive block #989.

Scenario("Bullets around the cursor")
	o1 = new stzString("12•4•67")
	Then("next after 3", o1.FindNext("•", :StartingAt = 3), 5)
	Then("no 2nd next after 3",
		o1.FindNextNth(2, "•", :StartingAt = 3), 0)
	Then("previous before 5", o1.FindPrevious("•", :StartingAt = 5), 3)
	Then("no 2nd previous before 5",
		o1.FindPreviousNth(2, "•", :StartingAt = 5), 0)
EndScenario()

Summary()
