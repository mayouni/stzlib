load "../../stzBase.ring"
load "../_narrated.ring"

# NextOccurrence and NthPreviousOccurrence. Archive block #697.

Scenario("Forward once, backward twice")
	o1 = new stzString("---Mio---Mio---Mio---Mio---")
	Then("next from 1", o1.NextOccurrence("Mio", :StartingAt = 1), 4)
	Then("2nd before 15",
		o1.NthPreviousOccurrence(2, "Mio", :StartingAt = 15), 4)
	Then("4th before 25",
		o1.NthPreviousOccurrence(4, "Mio", :StartingAt = 25), 4)
EndScenario()

Summary()
