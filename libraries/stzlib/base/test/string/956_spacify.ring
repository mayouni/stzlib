load "../../stzBase.ring"
load "../_narrated.ring"

# Spacify then VizFind: the carets land on the spaced-out positions.
# Archive block #956.

Scenario("Marking the As of a spaced string")
	Then("four carets, doubled gaps",
		Q("ABTCADNBBABEFACCC").SpacifyQ().vizFind("A"),
		"A B T C A D N B B A B E F A C C C" + NL +
		"^-------^---------^-------^------")
EndScenario()

Summary()
