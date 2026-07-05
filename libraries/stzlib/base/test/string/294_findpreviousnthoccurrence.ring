load "../../stzBase.ring"
load "../_narrated.ring"

# Finding brackets around a cursor in a deep-list string -- the named
# and the FindFirst spellings agree. Archive block #294.

Scenario("Brackets around position 21")
	o1 = new stzString( '[ "1", "1", [ "2", "♥", "2"], "1", [ "2", ["3", "♥"] ] ]' )
	Then("previous open bracket",
		o1.FindPreviousNthOccurrence(1, :Of = "[", :StartingAt = 21), 13)
	Then("next close bracket",
		o1.FindNextNthOccurrence(1, :Of = "]", :StartingAt = 21), 28)
	Then("first previous, same",
		o1.FindFirstPrevious("[", :StartingAt = 21), 13)
	Then("first next, same",
		o1.FindFirstNext(:Of = "]", :StartingAt = 21), 28)
EndScenario()

Summary()
