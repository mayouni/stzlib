load "../../stzBase.ring"
load "../_narrated.ring"

# VizFind draws the text and a caret rail underneath -- carets on the
# hits, dashes elsewhere. Archive block #900.

Scenario("Marking every A")
	Then("four carets on the rail",
		StzStringQ("ABTCADNBBABEFACCC").VizFind("A"),
		"ABTCADNBBABEFACCC" + NL + "^---^----^---^---")
EndScenario()

Summary()
