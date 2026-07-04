load "../../stzBase.ring"
load "../_narrated.ring"

# Longer replacements grow the string. Archive block #970.

Scenario("Carets become their positions")
	o1 = new stzString("^---^---^---^---")
	o1.ReplaceSectionsByMany(
		[ [ 1, 1 ], [ 5, 5 ], [ 9, 9 ], [ 13, 14 ] ],
		[ "1", "5", "9", "13" ]
	)
	Then("self-describing", o1.Content(), "1---5---9---13--")
EndScenario()

Summary()
