load "../../stzBase.ring"
load "../_narrated.ring"

# ReplaceSectionsByMany with proper ascending sections.
# Archive block #926.

Scenario("Three sections, three names")
	o1 = new stzString("...456...012...678..")
	o1.ReplaceSectionsByMany([ [ 4, 6 ], [ 10, 12 ], [ 16, 18 ] ],
		[ "A", "BB", "CCC" ])
	Then("each section renamed", o1.Content(), "...A...BB...CCC..")
EndScenario()

Summary()
